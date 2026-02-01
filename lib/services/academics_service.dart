import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/academics_models.dart';
import 'supabase_data_service.dart';

class AcademicsService extends ChangeNotifier {
  List<ScheduleEntry> _schedule = [];
  List<TodoItem> _todos = [];
  final SupabaseDataService _dataService = SupabaseDataService();

  List<ScheduleEntry> get schedule => _schedule;
  List<TodoItem> get todos => _todos;
  List<TodoItem> get incompleteTodos => _todos.where((t) => !t.isCompleted).toList();
  List<TodoItem> get completedTodos => _todos.where((t) => t.isCompleted).toList();

  String exportData() {
    final data = {
      'schedule': _schedule.map((e) => e.toJson()).toList(),
      // Exporting cloud todos as JSON for backup, though they are in cloud now
      'todos': _todos.map((t) => t.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  Future<bool> importData(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      if (data.containsKey('schedule')) {
        final List<dynamic> scheduleList = data['schedule'];
        _schedule = scheduleList.map((e) => ScheduleEntry.fromJson(e)).toList();
        await _saveSchedule();
      }
      // We generally don't import todos back to cloud to avoid duplicates, 
      // but we could if needed. For now, we focus on Schedule import.
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  AcademicsService() {
    _loadData();
  }

  // ===== SCHEDULE METHODS (Local Only for now) =====
  
  Future<void> addScheduleEntry(ScheduleEntry entry) async {
    _schedule.add(entry);
    await _saveSchedule();
    notifyListeners();
  }

  Future<void> updateScheduleEntry(ScheduleEntry entry) async {
    final index = _schedule.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _schedule[index] = entry;
      await _saveSchedule();
      notifyListeners();
    }
  }

  Future<void> deleteScheduleEntry(String id) async {
    _schedule.removeWhere((e) => e.id == id);
    await _saveSchedule();
    notifyListeners();
  }

  List<ScheduleEntry> getScheduleForDay(int dayOfWeek) {
    return _schedule.where((e) => e.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // ===== PERSISTENCE =====
  
  bool get _isGuest => Supabase.instance.client.auth.currentUser == null;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load schedule (always local)
    final scheduleJson = prefs.getString('academics_schedule');
    if (scheduleJson != null) {
      final List<dynamic> scheduleList = jsonDecode(scheduleJson);
      _schedule = scheduleList.map((e) => ScheduleEntry.fromJson(e)).toList();
    }
    
    // Load Todos
    if (_isGuest) {
       final todosJson = prefs.getString('academics_todos');
       if (todosJson != null) {
          final List<dynamic> todosList = jsonDecode(todosJson);
          _todos = todosList.map((e) => TodoItem.fromJson(e)).toList();
       }
    } else {
      try {
        final cloudTodos = await _dataService.fetchTasks();
        // If cloud has data, use it. If empty, maybe first sync? 
        // For now, simple replacement.
        _todos = cloudTodos; 
      } catch (e) {
        debugPrint("Failed to load cloud tasks: $e");
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleJson = jsonEncode(_schedule.map((e) => e.toJson()).toList());
    await prefs.setString('academics_schedule', scheduleJson);
  }

  Future<void> _saveLocalTodos() async {
    if (!_isGuest) return; // Don't overwrite local with empty if we are cloud
    final prefs = await SharedPreferences.getInstance();
    final todosJson = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString('academics_todos', todosJson);
  }

  // ===== TODO METHODS (Hybrid) =====
  
  Future<void> addTodo(TodoItem todo) async {
    _todos.insert(0, todo);
    notifyListeners();
      
    if (_isGuest) {
      await _saveLocalTodos();
    } else {
      try {
        final newTodo = await _dataService.addTask(todo);
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = newTodo;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Add todo failed: $e');
        _todos.removeWhere((t) => t.id == todo.id);
        notifyListeners();
      }
    }
  }

  Future<void> updateTodo(TodoItem todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      final oldTodo = _todos[index];
      _todos[index] = todo;
      notifyListeners();
      
      if (_isGuest) {
        await _saveLocalTodos();
      } else {
        try {
          await _dataService.updateTask(todo);
        } catch (e) {
          _todos[index] = oldTodo;
          notifyListeners();
        }
      }
    }
  }

  Future<void> toggleTodoComplete(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTodo = _todos[index];
      final newTodo = oldTodo.copyWith(isCompleted: !oldTodo.isCompleted);
      
      _todos[index] = newTodo;
      notifyListeners();
      
      if (_isGuest) {
        await _saveLocalTodos();
      } else {
        try {
          await _dataService.updateTask(newTodo);
        } catch (e) {
           _todos[index] = oldTodo;
           notifyListeners();
        }
      }
    }
  }

  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final deleted = _todos[index];
      _todos.removeAt(index);
      notifyListeners();
      
      if (_isGuest) {
        await _saveLocalTodos();
      } else {
        try {
          await _dataService.deleteTask(id);
        } catch (e) {
          _todos.insert(index, deleted);
          notifyListeners();
        }
      }
    }
  }

  // No specific _saveTodos needed as we direct sync, although caching is good practice for offline.

  List<TodoItem> getTodosByPriority(Priority priority) {
    return _todos.where((t) => t.priority == priority && !t.isCompleted).toList();
  }

  List<TodoItem> getOverdueTodos() {
    final now = DateTime.now();
    return _todos.where((t) => 
      !t.isCompleted && 
      t.dueDate != null && 
      t.dueDate!.isBefore(now)
    ).toList();
  }

  // ===== SAMPLE DATA FOR DEMO =====
  
  Future<void> loadSampleData() async {
    // Only loads local schedule sample
    final now = DateTime.now();
    _schedule = [
      ScheduleEntry(
        id: '1',
        subject: 'Mathematics',
        teacher: 'Mr. Kim',
        room: 'Room 301',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        dayOfWeek: 1, // Monday
        color: const Color(0xFF6C63FF),
      ),
       ScheduleEntry(
        id: '2',
        subject: 'English',
        teacher: 'Ms. Park',
        room: 'Room 205',
        startTime: DateTime(now.year, now.month, now.day, 10, 15),
        endTime: DateTime(now.year, now.month, now.day, 11, 15),
        dayOfWeek: 1,
        color: const Color(0xFFFF6584),
      ),
    ];
    await _saveSchedule();
    notifyListeners();
  }
}

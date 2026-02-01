/// SINO - Supabase Data Service
/// 
/// This service handles all database operations with Supabase.
/// It provides CRUD operations for mood entries, academic tasks,
/// and user points.
/// 
/// ## Features
/// - Mood entry persistence
/// - Academic task management
/// - Points/rewards synchronization
/// - Automatic user scoping via RLS
/// 
/// ## Usage
/// ```dart
/// final dataService = SupabaseDataService();
/// 
/// // Fetch mood entries from last 7 days
/// final entries = await dataService.fetchMoodEntries(days: 7);
/// 
/// // Add a new task
/// final task = await dataService.addTask(TodoItem(...));
/// ```
/// 
/// ## Security
/// All queries are automatically scoped to the current user
/// via Supabase Row Level Security (RLS) policies.
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mood_models.dart';
import '../models/academics_models.dart';

// ============================================================
// SUPABASE DATA SERVICE
// ============================================================

/// Service for database operations with Supabase.
/// 
/// This service acts as a repository layer between the app
/// and Supabase PostgreSQL database. All operations are
/// automatically scoped to the authenticated user.
class SupabaseDataService {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// Access to the Supabase client singleton.
  SupabaseClient get _supabase => Supabase.instance.client;
  
  /// The currently authenticated user, or null if not logged in.
  User? get _currentUser => _supabase.auth.currentUser;
  
  /// Whether a user is currently authenticated.
  bool get isAuthenticated => _currentUser != null;

  // ============================================================
  // MOOD ENTRIES
  // ============================================================

  /// Fetches mood entries for the current user.
  /// 
  /// [days] Number of days to look back (default: 30).
  /// 
  /// Returns an empty list if not authenticated or on error.
  /// 
  /// Example:
  /// ```dart
  /// final entries = await dataService.fetchMoodEntries(days: 7);
  /// for (var entry in entries) {
  ///   print('${entry.timestamp}: ${entry.mood}');
  /// }
  /// ```
  Future<List<MoodEntry>> fetchMoodEntries({int days = 30}) async {
    if (_currentUser == null) {
      debugPrint('⚠️ fetchMoodEntries: No authenticated user');
      return [];
    }

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await _supabase
          .from('mood_entries')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      final entries = (response as List)
          .map((e) => MoodEntry.fromJson(e))
          .toList();
      
      debugPrint('📊 Fetched ${entries.length} mood entries');
      return entries;
    } catch (e) {
      debugPrint('❌ Error fetching mood entries: $e');
      return [];
    }
  }

  /// Adds a new mood entry to the database.
  /// 
  /// [entry] The mood entry to persist.
  /// 
  /// Throws if the user is not authenticated or insert fails.
  Future<void> addMoodEntry(MoodEntry entry) async {
    if (_currentUser == null) {
      debugPrint('⚠️ addMoodEntry: No authenticated user');
      return;
    }

    try {
      await _supabase.from('mood_entries').insert({
        'user_id': _currentUser!.id,
        'mood_level': entry.mood.index,
        'sentiment_score': entry.sentimentScore,
        'context': entry.context,
        'source': entry.source.name,
        'metadata': entry.metadata,
        'created_at': entry.timestamp.toIso8601String(),
      });
      
      debugPrint('📊 Mood entry added successfully');
    } catch (e) {
      debugPrint('❌ Error adding mood entry: $e');
      rethrow;
    }
  }

  // ============================================================
  // ACADEMIC TASKS
  // ============================================================

  /// Fetches all tasks for the current user.
  /// 
  /// Returns tasks ordered by creation date (newest first).
  /// Returns an empty list if not authenticated or on error.
  Future<List<TodoItem>> fetchTasks() async {
    if (_currentUser == null) {
      debugPrint('⚠️ fetchTasks: No authenticated user');
      return [];
    }

    try {
      final response = await _supabase
          .from('academic_tasks')
          .select()
          .order('created_at', ascending: false);

      final tasks = (response as List)
          .map((e) => TodoItem.fromJson(e))
          .toList();
      
      debugPrint('📚 Fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error fetching tasks: $e');
      return [];
    }
  }

  /// Adds a new task to the database.
  /// 
  /// [task] The task to add.
  /// 
  /// Returns the created task with server-generated ID.
  /// Throws if user is not authenticated.
  Future<TodoItem> addTask(TodoItem task) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase.from('academic_tasks').insert({
        'user_id': _currentUser!.id,
        'title': task.title,
        'description': task.description,
        'due_date': task.dueDate?.toIso8601String(),
        'priority': task.priority.index,
        'is_completed': task.isCompleted,
        'subject': task.subject,
      }).select().single();

      debugPrint('📚 Task added: ${task.title}');
      return TodoItem.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error adding task: $e');
      rethrow;
    }
  }

  /// Updates an existing task.
  /// 
  /// [task] The task with updated values.
  Future<void> updateTask(TodoItem task) async {
    if (_currentUser == null) {
      debugPrint('⚠️ updateTask: No authenticated user');
      return;
    }

    try {
      await _supabase.from('academic_tasks').update({
        'title': task.title,
        'description': task.description,
        'due_date': task.dueDate?.toIso8601String(),
        'priority': task.priority.index,
        'is_completed': task.isCompleted,
        'subject': task.subject,
      }).eq('id', task.id);
      
      debugPrint('📚 Task updated: ${task.title}');
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      rethrow;
    }
  }

  /// Deletes a task by ID.
  /// 
  /// [taskId] The ID of the task to delete.
  Future<void> deleteTask(String taskId) async {
    if (_currentUser == null) {
      debugPrint('⚠️ deleteTask: No authenticated user');
      return;
    }

    try {
      await _supabase.from('academic_tasks').delete().eq('id', taskId);
      debugPrint('📚 Task deleted: $taskId');
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
      rethrow;
    }
  }

  // ============================================================
  // POINTS / REWARDS
  // ============================================================

  /// Fetches the user's current SINO points balance.
  /// 
  /// Returns 0 if not authenticated or on error.
  Future<int> fetchPoints() async {
    if (_currentUser == null) {
      debugPrint('⚠️ fetchPoints: No authenticated user');
      return 0;
    }
    
    try {
      final response = await _supabase
          .from('profiles')
          .select('sino_points')
          .eq('id', _currentUser!.id)
          .single();
      
      final points = response['sino_points'] as int? ?? 0;
      debugPrint('🎁 Fetched points: $points');
      return points;
    } catch (e) {
      debugPrint('❌ Error fetching points: $e');
      return 0;
    }
  }

  /// Updates the user's points balance.
  /// 
  /// [newTotal] The new total points value.
  Future<void> updatePoints(int newTotal) async {
    if (_currentUser == null) {
      debugPrint('⚠️ updatePoints: No authenticated user');
      return;
    }

    try {
      await _supabase.from('profiles').update({
        'sino_points': newTotal,
      }).eq('id', _currentUser!.id);
      
      debugPrint('🎁 Points updated to: $newTotal');
    } catch (e) {
      debugPrint('❌ Error updating points: $e');
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Gets the current user's ID.
  /// 
  /// Returns null if not authenticated.
  String? get currentUserId => _currentUser?.id;

  /// Checks if the database is reachable.
  /// 
  /// Useful for connectivity checks.
  Future<bool> checkConnection() async {
    try {
      await _supabase.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      debugPrint('❌ Database connection check failed: $e');
      return false;
    }
  }
}

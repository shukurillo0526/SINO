import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../services/academics_service.dart';
import '../../controllers/mood_controller.dart';
import '../../controllers/rewards_controller.dart';
import '../../models/mood_models.dart';
import '../../services/sentiment_service.dart';
import '../../models/academics_models.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final academicsService = context.watch<AcademicsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Active'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${academicsService.incompleteTodos.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Completed'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.disabledColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${academicsService.completedTodos.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodoList(todos: academicsService.incompleteTodos, isCompleted: false),
          _TodoList(todos: academicsService.completedTodos, isCompleted: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final academicsService = context.read<AcademicsService>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    Priority selectedPriority = Priority.medium;
    DateTime? selectedDate;
    String? selectedSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add To-Do'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: Priority.values.map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(p.label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedPriority = value!),
                ),
                const SizedBox(height: 16),
                
                // Subject Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject (Link to schedule)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No Subject')),
                    ...academicsService.schedule
                      .map((e) => e.subject)
                      .toSet()
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                  ],
                  onChanged: (val) => setState(() => selectedSubject = val),
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(selectedDate == null 
                    ? 'No due date' 
                    : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                  trailing: selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => selectedDate = null),
                      )
                    : null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                
                final todo = TodoItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  dueDate: selectedDate,
                  priority: selectedPriority,
                  subject: selectedSubject,
                );
                
                context.read<AcademicsService>().addTodo(todo);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  final List<TodoItem> todos;
  final bool isCompleted;

  const _TodoList({
    required this.todos,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.inbox_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed tasks yet' : 'No active tasks',
              style: TextStyle(color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _TodoCard(todo: todo);
      },
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoItem todo;

  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = todo.dueDate != null && 
                      todo.dueDate!.isBefore(DateTime.now()) && 
                      !todo.isCompleted;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<AcademicsService>().deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${todo.title} deleted')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue 
              ? Colors.red.withOpacity(0.3) 
              : todo.priority.color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Priority bar
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red : todo.priority.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              
              // Checkbox
              Checkbox(
                value: todo.isCompleted,
                onChanged: (val) {
                  final isChecking = val ?? false;
                  context.read<AcademicsService>().toggleTodoComplete(todo.id);
                  final lang = context.read<LanguageController>();
                  
                  if (isChecking) {
                    final sentiment = SentimentService.getTaskCompletionSentiment();
                    context.read<MoodController>().addMoodFromService(
                      MoodSource.academics,
                      sentiment,
                      context: 'Completed task: ${todo.title}',
                    );
                    
                    // Award SINO points (20 per task)
                    context.read<RewardsController>().addPoints(20);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.isEnglish ? 'Task Complete! +20 SINO Points 🌟' : '작업 완료! +20 SINO 포인트 🌟'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // Deduct points if unchecked to prevent farming
                    // But don't go below zero (logic inside controller can handle checks, but we'll send negative)
                    context.read<RewardsController>().addPoints(-20);
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.isEnglish ? 'Task unmarked. -20 SINO Points' : '작업 취소됨. -20 SINO 포인트'),
                        backgroundColor: Colors.grey,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted ? theme.disabledColor : null,
                        ),
                      ),
                      if (todo.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (todo.subject != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            todo.subject!,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isOverdue ? Colors.red : theme.disabledColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(todo.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue ? Colors.red : theme.disabledColor,
                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

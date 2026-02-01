import 'package:flutter/material.dart';

class ScheduleEntry {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final Color color;

  ScheduleEntry({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'teacher': teacher,
    'room': room,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'dayOfWeek': dayOfWeek,
    'color': color.value,
  };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
    id: json['id'],
    subject: json['subject'],
    teacher: json['teacher'],
    room: json['room'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    dayOfWeek: json['dayOfWeek'],
    color: Color(json['color']),
  );
}

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final Priority priority;
  final bool isCompleted;
  final String? subject;

  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.subject,
  });

  TodoItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    String? subject,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      subject: subject ?? this.subject,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority.index,
    'isCompleted': isCompleted,
    'subject': subject,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    // Helper to get value from either snake_case or camelCase key
    T? get<T>(String snake, String camel) {
      return (json[snake] ?? json[camel]) as T?;
    }

    final dateStr = get<String>('due_date', 'dueDate');

    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: dateStr != null ? DateTime.parse(dateStr) : null,
      priority: Priority.values[(json['priority'] as int?) ?? 1],
      isCompleted: (get<bool>('is_completed', 'isCompleted') ?? false),
      subject: json['subject'],
    );
  }
}

enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return const Color(0xFF4ECDC4);
      case Priority.medium:
        return const Color(0xFFFFC75F);
      case Priority.high:
        return const Color(0xFFFF6584);
    }
  }
}

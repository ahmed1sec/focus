import 'dart:convert';

enum TaskPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
    }
  }

  String get emoji {
    switch (this) {
      case TaskPriority.high:
        return '🔴';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.low:
        return '🟢';
    }
  }
}

class TodoTask {
  String id;
  String title;
  String description;
  TaskPriority priority;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? completedAt;

  TodoTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      priority: TaskPriority.values[map['priority']],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoTask.fromJson(String source) => TodoTask.fromMap(json.decode(source));

  TodoTask copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}


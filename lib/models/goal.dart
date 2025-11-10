import 'dart:convert';

class GoalSubtask {
  String id;
  String title;
  bool isCompleted;

  GoalSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory GoalSubtask.fromMap(Map<String, dynamic> map) {
    return GoalSubtask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalSubtask.fromJson(String source) =>
      GoalSubtask.fromMap(json.decode(source));

  GoalSubtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return GoalSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Goal {
  String id;
  String name;
  String category;
  List<GoalSubtask> subtasks;
  DateTime createdAt;
  DateTime? dueDate;
  bool isCompleted;

  Goal({
    required this.id,
    required this.name,
    this.category = 'Study',
    required this.subtasks,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
  });

  double get progress {
    if (subtasks.isEmpty) return 0.0;
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    return completedCount / subtasks.length;
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? 'Study',
      subtasks: (map['subtasks'] as List?)
              ?.map((s) => GoalSubtask.fromMap(s))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));

  Goal copyWith({
    String? id,
    String? name,
    String? category,
    List<GoalSubtask>? subtasks,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}


import 'package:equatable/equatable.dart';
import 'package:focus/models/goal.dart';
import 'package:focus/models/todo_task.dart';
import 'package:intl/intl.dart';

const Object _noChange = Object();

class TasksGoalsState extends Equatable {
  final bool isLoading;
  final List<TodoTask> tasks;
  final List<Goal> goals;
  final int currentTab; // 0 = tasks, 1 = goals
  final bool completedTasksExpanded;
  final bool completedGoalsExpanded;
  final Map<String, bool> goalExpanded;
  final DateTime? selectedDate;
  final String searchQuery;
  final String taskSortBy;
  final String goalSortBy;
  final String? errorMessage;

  const TasksGoalsState({
    required this.isLoading,
    required this.tasks,
    required this.goals,
    required this.currentTab,
    required this.completedTasksExpanded,
    required this.completedGoalsExpanded,
    required this.goalExpanded,
    required this.selectedDate,
    required this.searchQuery,
    required this.taskSortBy,
    required this.goalSortBy,
    this.errorMessage,
  });

  factory TasksGoalsState.initial() {
    return TasksGoalsState(
      isLoading: true,
      tasks: const [],
      goals: const [],
      currentTab: 0,
      completedTasksExpanded: false,
      completedGoalsExpanded: false,
      goalExpanded: const {},
      selectedDate: DateTime.now(),
      searchQuery: '',
      taskSortBy: 'priority',
      goalSortBy: 'date',
      errorMessage: null,
    );
  }

  TasksGoalsState copyWith({
    bool? isLoading,
    List<TodoTask>? tasks,
    List<Goal>? goals,
    int? currentTab,
    bool? completedTasksExpanded,
    bool? completedGoalsExpanded,
    Map<String, bool>? goalExpanded,
    Object? selectedDate = _noChange,
    String? searchQuery,
    String? taskSortBy,
    String? goalSortBy,
    Object? errorMessage = _noChange,
  }) {
    return TasksGoalsState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      goals: goals ?? this.goals,
      currentTab: currentTab ?? this.currentTab,
      completedTasksExpanded:
          completedTasksExpanded ?? this.completedTasksExpanded,
      completedGoalsExpanded:
          completedGoalsExpanded ?? this.completedGoalsExpanded,
      goalExpanded: goalExpanded ?? this.goalExpanded,
      selectedDate: selectedDate == _noChange
          ? this.selectedDate
          : selectedDate as DateTime?,
      searchQuery: searchQuery ?? this.searchQuery,
      taskSortBy: taskSortBy ?? this.taskSortBy,
      goalSortBy: goalSortBy ?? this.goalSortBy,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  List<TodoTask> get filteredTasks {
    final search = searchQuery.toLowerCase();
    final selected = selectedDate;

    final filtered = tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(search);

      if (selected == null) {
        return matchesSearch;
      }

      final selectedOnly = DateTime(selected.year, selected.month, selected.day);

      bool isDueOnDate = false;
      if (task.dueDate != null) {
        final due = task.dueDate!;
        final dueOnly = DateTime(due.year, due.month, due.day);
        isDueOnDate = dueOnly == selectedOnly;
      }

      final created = task.createdAt;
      final createdOnly = DateTime(created.year, created.month, created.day);
      final isCreatedOnDate = createdOnly == selectedOnly;

      bool isCompletedOnDate = false;
      if (task.completedAt != null) {
        final completed = task.completedAt!;
        final completedOnly =
            DateTime(completed.year, completed.month, completed.day);
        isCompletedOnDate = completedOnly == selectedOnly;
      }

      final matchesDate = isDueOnDate || isCreatedOnDate || isCompletedOnDate;
      return matchesSearch && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      switch (taskSortBy) {
        case 'date':
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          if (a.dueDate != null) return -1;
          if (b.dueDate != null) return 1;
          return a.createdAt.compareTo(b.createdAt);
        case 'title':
          return a.title.compareTo(b.title);
        case 'priority':
        default:
          return a.priority.index.compareTo(b.priority.index);
      }
    });

    return filtered;
  }

  List<TodoTask> get pendingTasks =>
      filteredTasks.where((task) => !task.isCompleted).toList();

  List<TodoTask> get completedTasks =>
      filteredTasks.where((task) => task.isCompleted).toList();

  List<Goal> get filteredGoals {
    final search = searchQuery.toLowerCase();

    final filtered = goals.where((goal) {
      final matchesSearch = goal.name.toLowerCase().contains(search) ||
          goal.subtasks
              .any((subtask) => subtask.title.toLowerCase().contains(search));

      if (selectedDate == null) {
        return matchesSearch;
      }

      final selectedOnly = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day);

      bool matchesDate = false;
      if (goal.dueDate != null) {
        final due = goal.dueDate!;
        final dueOnly = DateTime(due.year, due.month, due.day);
        matchesDate = dueOnly == selectedOnly;
      }

      final createdOnly = DateTime(
        goal.createdAt.year,
        goal.createdAt.month,
        goal.createdAt.day,
      );
      matchesDate = matchesDate || createdOnly == selectedOnly;

      return matchesSearch && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      switch (goalSortBy) {
        case 'title':
          return a.name.compareTo(b.name);
        case 'progress':
          return b.progress.compareTo(a.progress);
        case 'date':
        default:
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          if (a.dueDate != null) return -1;
          if (b.dueDate != null) return 1;
          return a.createdAt.compareTo(b.createdAt);
      }
    });

    return filtered;
  }

  List<Goal> get pendingGoals =>
      filteredGoals.where((goal) => !goal.isCompleted).toList();

  List<Goal> get completedGoals =>
      filteredGoals.where((goal) => goal.isCompleted).toList();

  String get selectedDateFormatted => selectedDate == null
      ? 'All Tasks'
      : DateFormat('MMM dd, yyyy').format(selectedDate!);

  @override
  List<Object?> get props => [
        isLoading,
        tasks,
        goals,
        currentTab,
        completedTasksExpanded,
        completedGoalsExpanded,
        goalExpanded,
        selectedDate,
        searchQuery,
        taskSortBy,
        goalSortBy,
        errorMessage,
      ];
}

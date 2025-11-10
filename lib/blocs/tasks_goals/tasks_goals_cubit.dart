import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus/models/goal.dart';
import 'package:focus/models/todo_task.dart';
import 'package:focus/services/storage_service.dart';

import 'tasks_goals_state.dart';

class TasksGoalsCubit extends Cubit<TasksGoalsState> {
  TasksGoalsCubit() : super(TasksGoalsState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    final savedTasks = StorageService.getStringList('todo_tasks') ?? [];
    final savedGoals = StorageService.getStringList('goals') ?? [];

    final tasks = savedTasks.map((json) => TodoTask.fromJson(json)).toList();
    final goals = savedGoals.map((json) => Goal.fromJson(json)).toList();

    final expanded = {for (final goal in goals) goal.id: true};

    emit(state.copyWith(
      isLoading: false,
      tasks: tasks,
      goals: goals,
      goalExpanded: expanded,
    ));
  }

  void changeTab(int index) {
    if (index == state.currentTab) return;
    emit(state.copyWith(currentTab: index));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void clearSelectedDate() {
    emit(state.copyWith(selectedDate: null));
  }

  void setTaskSortBy(String value) {
    emit(state.copyWith(taskSortBy: value));
  }

  void setGoalSortBy(String value) {
    emit(state.copyWith(goalSortBy: value));
  }

  void toggleCompletedTasksSection() {
    emit(state.copyWith(
      completedTasksExpanded: !state.completedTasksExpanded,
    ));
  }

  void toggleCompletedGoalsSection() {
    emit(state.copyWith(
      completedGoalsExpanded: !state.completedGoalsExpanded,
    ));
  }

  void toggleGoalExpanded(String goalId) {
    final updated = Map<String, bool>.from(state.goalExpanded);
    final current = updated[goalId] ?? true;
    updated[goalId] = !current;
    emit(state.copyWith(goalExpanded: updated));
  }

  Future<void> _persistTasks(List<TodoTask> tasks) async {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await StorageService.setStringList('todo_tasks', jsonList);
  }

  Future<void> _persistGoals(List<Goal> goals) async {
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    await StorageService.setStringList('goals', jsonList);
  }

  Future<void> addTask({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    final newTask = TodoTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    final updatedTasks = List<TodoTask>.from(state.tasks)..add(newTask);
    await _persistTasks(updatedTasks);
    emit(state.copyWith(tasks: updatedTasks));
  }

  Future<void> updateTask(TodoTask updatedTask) async {
    final updatedTasks = state.tasks
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();
    await _persistTasks(updatedTasks);
    emit(state.copyWith(tasks: updatedTasks));
  }

  Future<void> deleteTask(String taskId) async {
    final updatedTasks =
        state.tasks.where((task) => task.id != taskId).toList();
    await _persistTasks(updatedTasks);
    emit(state.copyWith(tasks: updatedTasks));
  }

  Future<void> toggleTaskCompletion(String taskId, bool value) async {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          isCompleted: value,
          completedAt: value ? DateTime.now() : null,
        );
      }
      return task;
    }).toList();

    await _persistTasks(updatedTasks);
    emit(state.copyWith(tasks: updatedTasks));
  }

  Future<void> addGoal(Goal goal) async {
    final updatedGoals = List<Goal>.from(state.goals)..add(goal);
    final expanded = Map<String, bool>.from(state.goalExpanded);
    expanded[goal.id] = true;
    await _persistGoals(updatedGoals);
    emit(state.copyWith(goals: updatedGoals, goalExpanded: expanded));
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final updatedGoals = state.goals
        .map((goal) => goal.id == updatedGoal.id ? updatedGoal : goal)
        .toList();
    await _persistGoals(updatedGoals);
    emit(state.copyWith(goals: updatedGoals));
  }

  Future<void> deleteGoal(String goalId) async {
    final updatedGoals =
        state.goals.where((goal) => goal.id != goalId).toList();
    final expanded = Map<String, bool>.from(state.goalExpanded)
      ..remove(goalId);
    await _persistGoals(updatedGoals);
    emit(state.copyWith(goals: updatedGoals, goalExpanded: expanded));
  }

  Future<void> toggleSubtask(
      {required String goalId, required String subtaskId, required bool value}) async {
    final goal = state.goals.firstWhere((goal) => goal.id == goalId);
    final updatedSubtasks = goal.subtasks.map((subtask) {
      if (subtask.id == subtaskId) {
        return subtask.copyWith(isCompleted: value);
      }
      return subtask;
    }).toList();

    final isGoalCompleted =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isCompleted);

    final updatedGoal = goal.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: isGoalCompleted,
    );

    await updateGoal(updatedGoal);
  }

  Future<void> addSubtask(
      {required String goalId, required GoalSubtask subtask}) async {
    final goal = state.goals.firstWhere((goal) => goal.id == goalId);
    final updatedSubtasks = List<GoalSubtask>.from(goal.subtasks)..add(subtask);
    final updatedGoal = goal.copyWith(subtasks: updatedSubtasks);
    await updateGoal(updatedGoal);
  }

  Future<void> updateSubtask(
      {required String goalId, required GoalSubtask subtask}) async {
    final goal = state.goals.firstWhere((goal) => goal.id == goalId);
    final updatedSubtasks = goal.subtasks
        .map((item) => item.id == subtask.id ? subtask : item)
        .toList();
    final updatedGoal = goal.copyWith(subtasks: updatedSubtasks);
    await updateGoal(updatedGoal);
  }

  Future<void> deleteSubtask(
      {required String goalId, required String subtaskId}) async {
    final goal = state.goals.firstWhere((goal) => goal.id == goalId);
    final updatedSubtasks =
        goal.subtasks.where((subtask) => subtask.id != subtaskId).toList();
    final isGoalCompleted =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isCompleted);

    final updatedGoal = goal.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: isGoalCompleted,
    );

    await updateGoal(updatedGoal);
  }

  void toggleTaskExpansion(String goalId) {
    toggleGoalExpanded(goalId);
  }
}

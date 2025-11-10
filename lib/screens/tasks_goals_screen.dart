import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:focus/blocs/tasks_goals/tasks_goals_cubit.dart';
import 'package:focus/blocs/tasks_goals/tasks_goals_state.dart';
import 'package:focus/models/goal.dart';
import 'package:focus/models/todo_task.dart';
import 'package:focus/main.dart' as app;

class TasksGoalsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPomodoro;

  const TasksGoalsScreen({super.key, this.onNavigateToPomodoro});

  @override
  State<TasksGoalsScreen> createState() => _TasksGoalsScreenState();
}

class _TasksGoalsScreenState extends State<TasksGoalsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TasksGoalsCubit>();
    _searchController = TextEditingController(text: cubit.state.searchQuery);
    _searchController.addListener(() {
      context.read<TasksGoalsCubit>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksGoalsCubit, TasksGoalsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, state),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async =>
                      context.read<TasksGoalsCubit>().loadData(),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 12),
                      _buildSearchBar(context, state),
                      _buildTabs(context, state),
                      const SizedBox(height: 16),
                      if (state.currentTab == 0)
                        ..._buildTasksContent(context, state)
                      else
                        ..._buildGoalsContent(context, state),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
          floatingActionButton: _buildFab(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, TasksGoalsState state) {
    final cubit = context.read<TasksGoalsCubit>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: state.currentTab == 0 ? 64 : null,
      leading: state.currentTab == 0
          ? IconButton(
              icon: const Icon(Icons.calendar_today),
              tooltip: 'Select Date',
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: state.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (selected != null) {
                  cubit.setSelectedDate(selected);
                }
              },
            )
          : null,
      title: Text(
        state.currentTab == 0
            ? state.selectedDateFormatted
            : 'Goals Overview',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        if (state.currentTab == 0 && state.selectedDate != null)
          IconButton(
            tooltip: 'Show all tasks',
            icon: const Icon(Icons.clear_all),
            onPressed: cubit.clearSelectedDate,
          ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          tooltip: Theme.of(context).brightness == Brightness.dark
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
          onPressed: () {
            app.themeToggleCallback?.call();
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            if (state.currentTab == 0) {
              cubit.setTaskSortBy(value);
            } else {
              cubit.setGoalSortBy(value);
            }
          },
          itemBuilder: (context) {
            if (state.currentTab == 0) {
              return const [
                PopupMenuItem(value: 'priority', child: Text('Sort by Priority')),
                PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                PopupMenuItem(value: 'title', child: Text('Sort by Title')),
              ];
            }
            return const [
              PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              PopupMenuItem(value: 'title', child: Text('Sort by Title')),
              PopupMenuItem(value: 'progress', child: Text('Sort by Progress')),
            ];
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TasksGoalsState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-driven colors so light/dark match perfectly
    final background = theme.colorScheme.surface;
    final border = theme.colorScheme.outline.withValues(alpha: 0.12);
    final iconColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Icon(Icons.search, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks & goals',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.searchQuery.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('clear'),
                      icon:
                          Icon(Icons.close_rounded, color: iconColor, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        context.read<TasksGoalsCubit>().setSearchQuery('');
                      },
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, TasksGoalsState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<TasksGoalsCubit>().changeTab(0),
              child: _buildTabItem(
                context,
                label: 'Tasks',
                isActive: state.currentTab == 0,
                theme: theme,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<TasksGoalsCubit>().changeTab(1),
              child: _buildTabItem(
                context,
                label: 'Goals',
                isActive: state.currentTab == 1,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context,
      {required String label,
      required bool isActive,
      required ThemeData theme}) {
    final isDark = theme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isActive
            ? LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ])
            : LinearGradient(colors: [
                isDark ? const Color(0xFF22273a) : Colors.white,
                isDark ? const Color(0xFF1b1f32) : theme.cardColor,
              ]),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTasksContent(
      BuildContext context, TasksGoalsState state) {
    final theme = Theme.of(context);
    final cubit = context.read<TasksGoalsCubit>();

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Tasks Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                _CurrentDayChip(date: DateTime.now(), theme: theme),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Pending Tasks ⏳',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (state.pendingTasks.isEmpty)
              _buildEmptyState(
                context,
                message: state.selectedDate == null
                    ? 'No pending tasks yet.'
                    : 'No tasks scheduled for ${state.selectedDateFormatted}.',
              )
            else
              ...state.pendingTasks.map(
                (task) => _TaskCard(
                  task: task,
                  theme: theme,
                  onToggleCompleted: (value) =>
                      cubit.toggleTaskCompletion(task.id, value ?? false),
                  onEdit: () => _showTaskDialog(context, task: task),
                  onDelete: () => _confirmDeleteTask(context, task.id),
                ),
              ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: cubit.toggleCompletedTasksSection,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Tasks ✅',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Icon(state.completedTasksExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.completedTasksExpanded
                  ? (state.completedTasks.isEmpty
                      ? _buildEmptyState(context,
                          message: 'No completed tasks for this day.')
                      : Column(
                          children: state.completedTasks
                              .map((task) => _TaskCard(
                                    task: task,
                                    theme: theme,
                                    onToggleCompleted: (value) => cubit
                                        .toggleTaskCompletion(task.id, value ?? false),
                                    onEdit: () =>
                                        _showTaskDialog(context, task: task),
                                    onDelete: () =>
                                        _confirmDeleteTask(context, task.id),
                                  ))
                              .toList(),
                        ))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildGoalsContent(
      BuildContext context, TasksGoalsState state) {
    final theme = Theme.of(context);
    final cubit = context.read<TasksGoalsCubit>();

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            if (state.pendingGoals.isEmpty)
              _buildEmptyState(context,
                  message: state.selectedDate == null
                      ? 'No goals yet. Start by creating one.'
                      : 'No goals scheduled for ${state.selectedDateFormatted}.'
                          ' Tap the + button to add a new goal.')
            else
              ...state.pendingGoals.map((goal) {
                final isExpanded = state.goalExpanded[goal.id] ?? true;
                return _GoalCard(
                  goal: goal,
                  theme: theme,
                  expanded: isExpanded,
                  onToggleExpanded: () => cubit.toggleGoalExpanded(goal.id),
                  onEdit: () => _showGoalDialog(context, goal: goal),
                  onDelete: () => _confirmDeleteGoal(context, goal.id),
                  onAddSubtask: () =>
                      _showAddSubtaskDialog(context, goalId: goal.id),
                  onEditSubtask: (subtask) =>
                      _showEditSubtaskDialog(context, goalId: goal.id, subtask: subtask),
                  onDeleteSubtask: (subtask) =>
                      _confirmDeleteSubtask(context, goalId: goal.id, subtaskId: subtask.id),
                  onToggleSubtask: (subtask, value) => cubit.toggleSubtask(
                      goalId: goal.id,
                      subtaskId: subtask.id,
                      value: value ?? false),
                  onStartPomodoro: widget.onNavigateToPomodoro,
                );
              }),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: cubit.toggleCompletedGoalsSection,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Goals ✅',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Icon(state.completedGoalsExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.completedGoalsExpanded
                  ? (state.completedGoals.isEmpty
                      ? _buildEmptyState(context,
                          message: 'No completed goals for this day.')
                      : Column(
                          children: state.completedGoals
                              .map((goal) => _GoalCard(
                                    goal: goal,
                                    theme: theme,
                                    expanded:
                                        state.goalExpanded[goal.id] ?? false,
                                    onToggleExpanded: () =>
                                        cubit.toggleGoalExpanded(goal.id),
                                    onEdit: () =>
                                        _showGoalDialog(context, goal: goal),
                                    onDelete: () =>
                                        _confirmDeleteGoal(context, goal.id),
                                    onAddSubtask: () => _showAddSubtaskDialog(
                                        context, goalId: goal.id),
                                    onEditSubtask: (subtask) =>
                                        _showEditSubtaskDialog(context,
                                            goalId: goal.id, subtask: subtask),
                                    onDeleteSubtask: (subtask) =>
                                        _confirmDeleteSubtask(context,
                                            goalId: goal.id,
                                            subtaskId: subtask.id),
                                    onToggleSubtask: (subtask, value) =>
                                        cubit.toggleSubtask(
                                            goalId: goal.id,
                                            subtaskId: subtask.id,
                                            value: value ?? false),
                                    onStartPomodoro: widget.onNavigateToPomodoro,
                                  ))
                              .toList(),
                        ))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildEmptyState(BuildContext context, {required String message}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, TasksGoalsState state) {
    return FloatingActionButton.extended(
      heroTag: 'tasks_goals_fab',
      backgroundColor: Theme.of(context).colorScheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        state.currentTab == 0 ? 'Add Task' : 'Add Goal',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        if (state.currentTab == 0) {
          _showTaskDialog(context);
        } else {
          _showGoalDialog(context);
        }
      },
    );
  }

  Future<void> _showTaskDialog(BuildContext context, {TodoTask? task}) async {
    final cubit = context.read<TasksGoalsCubit>();
    final state = cubit.state;
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    TaskPriority selectedPriority = task?.priority ?? TaskPriority.medium;
    DateTime? selectedDueDate = task?.dueDate ?? state.selectedDate;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Task' : 'Add Task',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TaskPriority>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text('${priority.emoji} ${priority.label}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedPriority = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          selectedDueDate == null
                              ? 'No due date'
                              : DateFormat('MMM dd, yyyy').format(selectedDueDate!),
                        ),
                        trailing: selectedDueDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setDialogState(() => selectedDueDate = null),
                              )
                            : null,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? state.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDueDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.trim().isEmpty) return;
                              if (task != null) {
                                final updated = task.copyWith(
                                  title: titleController.text.trim(),
                                  priority: selectedPriority,
                                  dueDate: selectedDueDate,
                                );
                                await cubit.updateTask(updated);
                              } else {
                                await cubit.addTask(
                                  title: titleController.text.trim(),
                                  priority: selectedPriority,
                                  dueDate: selectedDueDate ?? state.selectedDate,
                                );
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                            ),
                            child: Text(
                              isEditing ? 'Save' : 'Add',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showGoalDialog(BuildContext context, {Goal? goal}) async {
    final cubit = context.read<TasksGoalsCubit>();
    final state = cubit.state;
    final isEditing = goal != null;

    final nameController = TextEditingController(text: goal?.name ?? '');
    final categoryController =
        TextEditingController(text: goal?.category ?? 'Study');
    DateTime? selectedDueDate = goal?.dueDate ?? state.selectedDate;

    final subtaskControllers = <TextEditingController>[];
    final subtaskIds = <String>[];

    if (goal != null) {
      for (final subtask in goal.subtasks) {
        subtaskIds.add(subtask.id);
        subtaskControllers.add(TextEditingController(text: subtask.title));
      }
    }

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Goal' : 'Add Goal',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          selectedDueDate == null
                              ? 'No due date'
                              : DateFormat('MMM dd, yyyy').format(selectedDueDate!),
                        ),
                        trailing: selectedDueDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setDialogState(() => selectedDueDate = null),
                              )
                            : null,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ??
                                state.selectedDate ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDueDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          for (int i = 0; i < subtaskControllers.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: subtaskControllers[i],
                                      decoration: InputDecoration(
                                        labelText: 'Subtask ${i + 1}',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Remove subtask',
                                    onPressed: () {
                                      setDialogState(() {
                                        subtaskControllers.removeAt(i).dispose();
                                        subtaskIds.removeAt(i);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                subtaskIds.add(DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString());
                                subtaskControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Subtask'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.trim().isEmpty) return;
                              final subtasks = <GoalSubtask>[];
                              for (var i = 0; i < subtaskControllers.length; i++) {
                                final text = subtaskControllers[i].text.trim();
                                if (text.isEmpty) continue;
                                subtasks.add(GoalSubtask(
                                  id: subtaskIds[i],
                                  title: text,
                                ));
                              }

                              final goalData = Goal(
                                id: goal?.id ??
                                    DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameController.text.trim(),
                                category: categoryController.text.trim(),
                                subtasks: subtasks,
                                createdAt: goal?.createdAt ?? DateTime.now(),
                                dueDate: selectedDueDate ??
                                    state.selectedDate ??
                                    DateTime.now().add(const Duration(days: 5)),
                                isCompleted: subtasks.isNotEmpty &&
                                    subtasks.every((s) => s.isCompleted),
                              );

                              if (isEditing) {
                                await cubit.updateGoal(goalData);
                              } else {
                                await cubit.addGoal(goalData);
                              }

                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                            ),
                            child: Text(
                              isEditing ? 'Save' : 'Add',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTask(BuildContext context, String taskId) async {
    final cubit = context.read<TasksGoalsCubit>();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await cubit.deleteTask(taskId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGoal(BuildContext context, String goalId) async {
    final cubit = context.read<TasksGoalsCubit>();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await cubit.deleteGoal(goalId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSubtaskDialog(BuildContext context,
      {required String goalId}) async {
    final cubit = context.read<TasksGoalsCubit>();
    final controller = TextEditingController();
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final subtask = GoalSubtask(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: controller.text.trim(),
              );
              await cubit.addSubtask(goalId: goalId, subtask: subtask);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSubtaskDialog(BuildContext context,
      {required String goalId, required GoalSubtask subtask}) async {
    final cubit = context.read<TasksGoalsCubit>();
    final controller = TextEditingController(text: subtask.title);
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Edit Subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await cubit.updateSubtask(
                goalId: goalId,
                subtask: subtask.copyWith(title: controller.text.trim()),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSubtask(BuildContext context,
      {required String goalId, required String subtaskId}) async {
    final cubit = context.read<TasksGoalsCubit>();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subtask'),
        content: const Text('Are you sure you want to delete this subtask?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await cubit.deleteSubtask(goalId: goalId, subtaskId: subtaskId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TodoTask task;
  final ThemeData theme;
  final ValueChanged<bool?> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.theme,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = task.priority == TaskPriority.high
        ? const Color(0xFFFF6B6B)
        : task.priority == TaskPriority.medium
            ? const Color(0xFFFFD166)
            : const Color(0xFF4ECDC4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? LinearGradient(colors: [
                const Color(0xFF1f2434),
                const Color(0xFF2c3147),
              ])
            : LinearGradient(colors: [
                const Color(0xFFF6F9FF),
                const Color(0xFFEAF1FE),
              ]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: priorityColor.withValues(alpha: 0.15),
              ),
              child: Checkbox(
                value: task.isCompleted,
                onChanged: onToggleCompleted,
                shape: const CircleBorder(),
                activeColor: priorityColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: task.priority.label, color: priorityColor),
                      const SizedBox(width: 8),
                      if (task.dueDate != null)
                        _Chip(
                          label: DateFormat('MMM dd').format(task.dueDate!),
                          color: theme.colorScheme.primary,
                          icon: Icons.calendar_today,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final ThemeData theme;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSubtask;
  final ValueChanged<GoalSubtask> onEditSubtask;
  final ValueChanged<GoalSubtask> onDeleteSubtask;
  final void Function(GoalSubtask subtask, bool? value) onToggleSubtask;
  final VoidCallback? onStartPomodoro;

  const _GoalCard({
    required this.goal,
    required this.theme,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSubtask,
    required this.onEditSubtask,
    required this.onDeleteSubtask,
    required this.onToggleSubtask,
    this.onStartPomodoro,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: isDark
            ? LinearGradient(colors: [
                const Color(0xFF1c2238),
                const Color(0xFF262d45),
              ])
            : LinearGradient(colors: [
                const Color(0xFFFDF6FF),
                const Color(0xFFEDEBFF),
              ]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _Chip(
                                label: goal.category,
                                color: theme.colorScheme.primary,
                              ),
                              if (goal.dueDate != null) ...[
                                const SizedBox(width: 8),
                                _Chip(
                                  label:
                                      'Due in ${goal.daysUntilDue} days',
                                  color: Colors.orangeAccent,
                                  icon: Icons.timer_outlined,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit Goal')),
                        PopupMenuItem(
                            value: 'delete', child: Text('Delete Goal')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onToggleExpanded,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtasks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 12),
                      for (final subtask in goal.subtasks)
                        _SubtaskTile(
                          subtask: subtask,
                          theme: theme,
                          onChanged: (value) =>
                              onToggleSubtask(subtask, value),
                          onEdit: () => onEditSubtask(subtask),
                          onDelete: () => onDeleteSubtask(subtask),
                        ),
                      TextButton.icon(
                        onPressed: onAddSubtask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Subtask'),
                      ),
                    ],
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onStartPomodoro,
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Start Pomodoro Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  final GoalSubtask subtask;
  final ThemeData theme;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubtaskTile({
    required this.subtask,
    required this.theme,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1f2334) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: subtask.isCompleted,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 15,
                decoration:
                    subtask.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _CurrentDayChip extends StatelessWidget {
  final DateTime date;
  final ThemeData theme;

  const _CurrentDayChip({required this.date, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.today, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            DateFormat('EEE, MMM dd').format(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

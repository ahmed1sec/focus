import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus/models/todo_task.dart';
import 'package:focus/services/storage_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final savedTasks = StorageService.getStringList('todo_tasks') ?? [];
    setState(() {
      _tasks = savedTasks.map((json) => TodoTask.fromJson(json)).toList();
      _sortTasks();
      _isLoading = false;
    });
  }

  void _saveTasks() async {
    final jsonList = _tasks.map((task) => task.toJson()).toList();
    await StorageService.setStringList('todo_tasks', jsonList);
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.priority.index.compareTo(b.priority.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCompleted,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (incompleteTasks.isNotEmpty) ...[
                      _buildSectionHeader('Active Tasks', incompleteTasks.length),
                      ...incompleteTasks.map((task) => _buildTaskCard(task)),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader('Completed', completedTasks.length),
                      ...completedTasks.map((task) => _buildTaskCard(task)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first task',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TodoTask task) {
    final priorityColor = task.priority == TaskPriority.high
        ? Colors.red
        : task.priority == TaskPriority.medium
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            setState(() {
              task.isCompleted = value ?? false;
              task.completedAt = task.isCompleted ? DateTime.now() : null;
              _sortTasks();
            });
            _saveTasks();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${task.priority.emoji} ${task.priority.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: priorityColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd').format(task.dueDate!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editTask(task);
            } else if (value == 'delete') {
              _deleteTask(task);
            }
          },
        ),
      ),
    );
  }

  void _addTask() {
    _showTaskDialog();
  }

  void _editTask(TodoTask task) {
    _showTaskDialog(task: task);
  }

  void _deleteTask(TodoTask task) {
    setState(() {
      _tasks.remove(task);
    });
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _tasks.add(task);
              _sortTasks();
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _clearCompleted() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: Text('Remove $completedCount completed task${completedCount > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((t) => t.isCompleted);
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({TodoTask? task}) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    TaskPriority selectedPriority = task?.priority ?? TaskPriority.medium;
    DateTime? selectedDueDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
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
                    setDialogState(() {
                      selectedPriority = value!;
                    });
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
                          onPressed: () {
                            setDialogState(() {
                              selectedDueDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDueDate = date;
                      });
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

                if (isEditing) {
                  setState(() {
                    task.title = titleController.text.trim();
                    task.description = descController.text.trim();
                    task.priority = selectedPriority;
                    task.dueDate = selectedDueDate;
                    _sortTasks();
                  });
                } else {
                  setState(() {
                    _tasks.add(TodoTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      priority: selectedPriority,
                      createdAt: DateTime.now(),
                      dueDate: selectedDueDate,
                    ));
                    _sortTasks();
                  });
                }
                _saveTasks();
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}


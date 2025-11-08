import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:focus/services/storage_service.dart';
import 'package:focus/models/todo_task.dart';
import 'package:focus/models/pomodoro_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  List<TodoTask> _tasks = [];
  List<PomodoroSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final name = StorageService.getString('user_name') ?? 'User';
    final savedTasks = StorageService.getStringList('todo_tasks') ?? [];
    final savedSessions = StorageService.getStringList('pomodoro_sessions') ?? [];

    setState(() {
      _userName = name;
      _tasks = savedTasks.map((json) => TodoTask.fromJson(json)).toList();
      _sessions = savedSessions.map((json) => PomodoroSession.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  int get _todayCompletedTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.isCompleted &&
          task.completedAt != null &&
          task.completedAt!.year == today.year &&
          task.completedAt!.month == today.month &&
          task.completedAt!.day == today.day;
    }).length;
  }

  int get _todayPomodoroSessions {
    final today = DateTime.now();
    return _sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          session.isCompleted;
    }).length;
  }

  int get _totalScreenTime {
    final today = DateTime.now();
    final todaySessions = _sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          session.isCompleted;
    });

    int totalMinutes = 0;
    for (var session in todaySessions) {
      totalMinutes += session.focusDuration + session.breakDuration;
    }
    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDailyStats(),
                  const SizedBox(height: 24),
                  _buildWeeklyChart(),
                  const SizedBox(height: 24),
                  _buildAchievements(),
                  const SizedBox(height: 24),
                  _buildSettings(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM dd').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  '✅',
                  _todayCompletedTasks.toString(),
                  'Tasks Done',
                  Colors.green,
                ),
                _buildStatCard(
                  '⏰',
                  '${_totalScreenTime}m',
                  'Focus Time',
                  Colors.blue,
                ),
                _buildStatCard(
                  '🍅',
                  _todayPomodoroSessions.toString(),
                  'Pomodoros',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final sessionsCount = _sessions.where((session) {
        return session.startTime.year == date.year &&
            session.startTime.month == date.month &&
            session.startTime.day == date.day &&
            session.isCompleted;
      }).length;
      return sessionsCount.toDouble();
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (weekData.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weekData[index],
                color: Theme.of(context).primaryColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      if (_todayCompletedTasks >= 5)
        Achievement('🏆', '5 Tasks Master', 'Completed 5 tasks today!'),
      if (_todayPomodoroSessions >= 4)
        Achievement('🔥', 'Focus Streak', '4 Pomodoro sessions today!'),
      if (_sessions.length >= 10)
        Achievement('⭐', 'Productivity Star', '10 total sessions completed!'),
      if (_tasks.where((t) => t.isCompleted).length >= 20)
        Achievement('💪', 'Task Warrior', '20 tasks completed overall!'),
    ];

    if (achievements.isEmpty) {
      achievements.add(
        Achievement('🎯', 'Getting Started', 'Keep going to unlock achievements!'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => ListTile(
                  leading: Text(
                    achievement.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    achievement.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(achievement.description),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Save your progress to cloud'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup feature coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage reminders and alerts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About FocusFlow'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _userName = controller.text.trim();
                });
                StorageService.setString('user_name', _userName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About FocusFlow'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FocusFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'A productivity and digital wellbeing app that helps you stay focused, manage your time, and reduce distractions.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 FocusFlow',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Achievement {
  final String emoji;
  final String title;
  final String description;

  Achievement(this.emoji, this.title, this.description);
}


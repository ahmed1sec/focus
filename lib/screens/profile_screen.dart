import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:focus/services/storage_service.dart';
import 'package:focus/models/todo_task.dart';
import 'package:focus/models/pomodoro_session.dart';

String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _selectedAvatar = '👤'; // Default avatar
  List<TodoTask> _tasks = [];
  List<PomodoroSession> _sessions = [];
  bool _isLoading = true;

  // Cartoon avatars for students
  static const List<Map<String, String>> _avatars = [
    {'emoji': '👨', 'name': 'Man', 'category': 'adult'},
    {'emoji': '👩', 'name': 'Woman', 'category': 'adult'},
    {'emoji': '👦', 'name': 'Boy', 'category': 'child'},
    {'emoji': '👧', 'name': 'Girl', 'category': 'child'},
    {'emoji': '🧑‍🎓', 'name': 'Student', 'category': 'student'},
    {'emoji': '👨‍🎓', 'name': 'Male Student', 'category': 'student'},
    {'emoji': '👩‍🎓', 'name': 'Female Student', 'category': 'student'},
    {'emoji': '🧑', 'name': 'Person', 'category': 'adult'},
    {'emoji': '🧒', 'name': 'Child', 'category': 'child'},
    {'emoji': '👤', 'name': 'Default', 'category': 'default'},
    {'emoji': '🦸', 'name': 'Superhero', 'category': 'fun'},
    {'emoji': '🦸‍♀️', 'name': 'Superheroine', 'category': 'fun'},
    {'emoji': '🧙', 'name': 'Wizard', 'category': 'fun'},
    {'emoji': '🧙‍♀️', 'name': 'Witch', 'category': 'fun'},
    {'emoji': '👨‍💻', 'name': 'Tech Student', 'category': 'student'},
    {'emoji': '👩‍💻', 'name': 'Tech Student', 'category': 'student'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final name = StorageService.getString('user_name') ?? 'User';
    final avatar = StorageService.getString('user_avatar') ?? '👤';
    final savedTasks = StorageService.getStringList('todo_tasks') ?? [];
    final savedSessions = StorageService.getStringList('pomodoro_sessions') ?? [];

    setState(() {
      _userName = name;
      _selectedAvatar = avatar;
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
            GestureDetector(
              onTap: _showAvatarSelection,
              child: CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                  _selectedAvatar,
                style: const TextStyle(
                    fontSize: 40,
                  ),
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
                    capitalizeWords(_userName),
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
    // Get the last 7 days starting from 6 days ago to today
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      
      // Count completed tasks for this day
      final tasksCount = _tasks.where((task) {
        return task.isCompleted &&
            task.completedAt != null &&
            task.completedAt!.year == date.year &&
            task.completedAt!.month == date.month &&
            task.completedAt!.day == date.day;
      }).length;
      
      // Count completed Pomodoro sessions for this day
      final sessionsCount = _sessions.where((session) {
        return session.startTime.year == date.year &&
            session.startTime.month == date.month &&
            session.startTime.day == date.day &&
            session.isCompleted;
      }).length;
      
      // Combine tasks and sessions for total productivity score
      return (tasksCount + sessionsCount).toDouble();
    });

    final maxValue = weekData.isEmpty ? 1.0 : (weekData.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    // Create spots for the line chart - week from 6 days ago to today
    final spots = List.generate(7, (index) {
      return FlSpot(index.toDouble(), weekData[index]);
    });

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxValue,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBgColor: Theme.of(context).primaryColor,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final date = now.subtract(Duration(days: 6 - touchedSpot.x.toInt()));
                final dateStr = DateFormat('MMM dd').format(date);
                return LineTooltipItem(
                  '$dateStr\n${touchedSpot.y.toInt()} activities',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= 7) return const SizedBox.shrink();
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                );
              },
              reservedSize: 30,
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
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).scaffoldBackgroundColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
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

  void _showAvatarSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Your Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              final isSelected = _selectedAvatar == avatar['emoji'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar['emoji']!;
                    StorageService.setString('user_avatar', _selectedAvatar);
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatar['emoji']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
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
              '© 2025 FocusFlow',
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


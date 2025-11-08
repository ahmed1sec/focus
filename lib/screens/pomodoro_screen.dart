import 'package:flutter/material.dart';
import 'dart:async';
import 'package:focus/models/pomodoro_session.dart';
import 'package:focus/services/storage_service.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  PomodoroSettings _settings = PomodoroSettings();
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isFocusMode = true;
  List<PomodoroSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSettings() async {
    final settingsJson = StorageService.getString('pomodoro_settings');
    if (settingsJson != null) {
      setState(() {
        _settings = PomodoroSettings.fromJson(settingsJson);
        _remainingSeconds = _settings.focusDuration * 60;
      });
    } else {
      setState(() {
        _remainingSeconds = _settings.focusDuration * 60;
      });
    }
  }

  void _saveSettings() async {
    await StorageService.setString('pomodoro_settings', _settings.toJson());
  }

  void _loadSessions() async {
    final savedSessions = StorageService.getStringList('pomodoro_sessions') ?? [];
    setState(() {
      _sessions = savedSessions.map((json) => PomodoroSession.fromJson(json)).toList();
    });
  }

  void _saveSessions() async {
    final jsonList = _sessions.map((session) => session.toJson()).toList();
    await StorageService.setStringList('pomodoro_sessions', jsonList);
  }

  int get _todaySessions {
    final today = DateTime.now();
    return _sessions.where((s) {
      return s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day &&
          s.isCompleted;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 32),
            _buildTimer(),
            const SizedBox(height: 32),
            _buildControls(),
            const SizedBox(height: 32),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              'Focus',
              Icons.psychology,
              _isFocusMode,
              () {
                if (!_isRunning) {
                  setState(() {
                    _isFocusMode = true;
                    _remainingSeconds = _settings.focusDuration * 60;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Break',
              Icons.coffee,
              !_isFocusMode,
              () {
                if (!_isRunning) {
                  setState(() {
                    _isFocusMode = false;
                    _remainingSeconds = _settings.breakDuration * 60;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = _isFocusMode
        ? 1 - (_remainingSeconds / (_settings.focusDuration * 60))
        : 1 - (_remainingSeconds / (_settings.breakDuration * 60));

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isFocusMode ? Theme.of(context).primaryColor : Colors.green,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isFocusMode ? 'Focus Time' : 'Break Time',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRunning)
          FloatingActionButton.large(
            onPressed: _pauseTimer,
            child: const Icon(Icons.pause, size: 32),
          )
        else
          FloatingActionButton.large(
            onPressed: _startTimer,
            child: const Icon(Icons.play_arrow, size: 32),
          ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: _resetTimer,
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '🍅',
                  _todaySessions.toString(),
                  'Sessions',
                ),
                _buildStatItem(
                  '⏱️',
                  '${_todaySessions * _settings.focusDuration}',
                  'Minutes',
                ),
                _buildStatItem(
                  '🔥',
                  _sessions.length.toString(),
                  'Total',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isFocusMode
          ? _settings.focusDuration * 60
          : _settings.breakDuration * 60;
    });
    _timer?.cancel();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    if (_isFocusMode) {
      // Save completed session
      final session = PomodoroSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now().subtract(Duration(minutes: _settings.focusDuration)),
        endTime: DateTime.now(),
        focusDuration: _settings.focusDuration,
        breakDuration: _settings.breakDuration,
        isCompleted: true,
      );
      _sessions.add(session);
      _saveSessions();
    }

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isFocusMode ? '🎉 Focus Complete!' : '☕ Break Complete!'),
        content: Text(
          _isFocusMode
              ? 'Great job! Time for a ${_settings.breakDuration}-minute break.'
              : 'Break\'s over! Ready for another focus session?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isFocusMode = !_isFocusMode;
                _remainingSeconds = _isFocusMode
                    ? _settings.focusDuration * 60
                    : _settings.breakDuration * 60;
              });
            },
            child: const Text('Switch Mode'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isFocusMode = !_isFocusMode;
                _remainingSeconds = _isFocusMode
                    ? _settings.focusDuration * 60
                    : _settings.breakDuration * 60;
              });
              if ((_isFocusMode && _settings.autoStartFocus) ||
                  (!_isFocusMode && _settings.autoStartBreak)) {
                _startTimer();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        settings: _settings,
        onSave: (newSettings) {
          setState(() {
            _settings = newSettings;
            if (!_isRunning) {
              _remainingSeconds = _isFocusMode
                  ? _settings.focusDuration * 60
                  : _settings.breakDuration * 60;
            }
          });
          _saveSettings();
        },
      ),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  final PomodoroSettings settings;
  final Function(PomodoroSettings) onSave;

  const _SettingsDialog({
    required this.settings,
    required this.onSave,
  });

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late PomodoroSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = PomodoroSettings(
      focusDuration: widget.settings.focusDuration,
      breakDuration: widget.settings.breakDuration,
      autoStartBreak: widget.settings.autoStartBreak,
      autoStartFocus: widget.settings.autoStartFocus,
      backgroundSound: widget.settings.backgroundSound,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pomodoro Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Focus Duration'),
              subtitle: Text('${_settings.focusDuration} minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_settings.focusDuration > 5) {
                        setState(() {
                          _settings.focusDuration -= 5;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_settings.focusDuration < 60) {
                        setState(() {
                          _settings.focusDuration += 5;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Break Duration'),
              subtitle: Text('${_settings.breakDuration} minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_settings.breakDuration > 5) {
                        setState(() {
                          _settings.breakDuration -= 5;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_settings.breakDuration < 30) {
                        setState(() {
                          _settings.breakDuration += 5;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Auto-start Break'),
              subtitle: const Text('Automatically start break after focus'),
              value: _settings.autoStartBreak,
              onChanged: (value) {
                setState(() {
                  _settings.autoStartBreak = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Auto-start Focus'),
              subtitle: const Text('Automatically start focus after break'),
              value: _settings.autoStartFocus,
              onChanged: (value) {
                setState(() {
                  _settings.autoStartFocus = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Background Sound'),
              subtitle: Text(_settings.backgroundSound ?? 'None'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSoundPicker();
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
            widget.onSave(_settings);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _showSoundPicker() {
    final sounds = ['None', 'Rain', 'Coffee Shop', 'White Noise', 'Forest'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Background Sound'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sounds.map((sound) {
            final soundValue = sound == 'None' ? '' : sound;
            final isSelected = (_settings.backgroundSound ?? '') == soundValue;
            return ListTile(
              title: Text(sound),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              onTap: () {
                setState(() {
                  _settings.backgroundSound = soundValue.isEmpty ? null : soundValue;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus/models/app_limit.dart';
import 'package:focus/services/storage_service.dart';
import 'package:focus/services/app_blocker_service.dart';
import 'package:focus/widgets/motivational_quote_dialog.dart';

class AppLimitsScreen extends StatefulWidget {
  const AppLimitsScreen({super.key});

  @override
  State<AppLimitsScreen> createState() => _AppLimitsScreenState();
}

class _AppLimitsScreenState extends State<AppLimitsScreen> with WidgetsBindingObserver {
  List<AppLimit> _appLimits = [];
  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _isBlocking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppLimits();
    _checkPermissionsAndStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh permissions when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndStatus();
    }
  }

  void _loadAppLimits() async {
    final savedLimits = StorageService.getStringList('app_limits') ?? [];
    setState(() {
      _appLimits = savedLimits.map((json) => AppLimit.fromJson(json)).toList();
      if (_appLimits.isEmpty) {
        _appLimits = AppLimit.getDefaultApps();
      }
      _isLoading = false;
    });
    _updateBlockingService();
  }

  void _checkPermissionsAndStatus() async {
    final hasPermission = await AppBlockerService.hasUsageStatsPermission();
    final isBlocking = await AppBlockerService.isBlocking();
    setState(() {
      _hasPermissions = hasPermission;
      _isBlocking = isBlocking;
    });
  }

  void _saveAppLimits() async {
    final jsonList = _appLimits.map((limit) => limit.toJson()).toList();
    await StorageService.setStringList('app_limits', jsonList);
    _updateBlockingService();
  }

  void _updateBlockingService() async {
    final enabledApps = _appLimits
        .where((app) => app.isEnabled)
        .map((app) => app.name)
        .toList();
    
    if (enabledApps.isEmpty) {
      await AppBlockerService.stopBlocking();
      setState(() {
        _isBlocking = false;
      });
    } else {
      // Always check permissions before starting blocking
      final hasPermission = await AppBlockerService.hasUsageStatsPermission();
      if (!hasPermission) {
        // Don't start blocking without permission
        setState(() {
          _isBlocking = false;
        });
        // Update permission status
        setState(() {
          _hasPermissions = false;
        });
        return;
      }
      
      // Start blocking if permission is granted
      final success = await AppBlockerService.startBlocking(enabledApps);
      setState(() {
        _isBlocking = success;
        _hasPermissions = true;
      });
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocking ${enabledApps.length} app(s)'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Limits'),
        actions: [
          if (!_hasPermissions)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: _showPermissionDialog,
              tooltip: 'Permissions Required',
            ),
          if (_isBlocking)
            IconButton(
              icon: const Icon(Icons.shield, color: Colors.green),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App blocking is active'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Blocking Active',
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appLimits.length,
              itemBuilder: (context, index) => _buildAppLimitCard(_appLimits[index]),
            ),
    );
  }

  Widget _buildAppLimitCard(AppLimit appLimit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: appLimit.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    appLimit.icon,
                    color: appLimit.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLimit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Blocked sections: ${appLimit.blockedSections.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: appLimit.isEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // Always check and request permissions when enabling
                      final hasPermission = await AppBlockerService.hasUsageStatsPermission();
                      if (!hasPermission) {
                        // Show dialog and request permissions
                        final shouldContinue = await _showPermissionDialogAndRequest();
                        if (!shouldContinue) {
                          // User cancelled or permission not granted
                          return;
                        }
                        // Re-check after user returns from settings
                        final stillNoPermission = !(await AppBlockerService.hasUsageStatsPermission());
                        if (stillNoPermission) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Permission is required to block apps. Please enable Usage Access.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                          return;
                        }
                      }
                    }
                    setState(() {
                      appLimit.isEnabled = value;
                    });
                    _saveAppLimits();
                  },
                ),
              ],
            ),
            if (appLimit.blockedSections.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Blocked Sections:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: appLimit.blockedSections.map((section) {
                  return Chip(
                    label: Text(section),
                    backgroundColor: appLimit.color.withValues(alpha: 0.1),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        appLimit.blockedSections.remove(section);
                      });
                      _saveAppLimits();
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _addBlockedSection(appLimit),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
                ),
                const Spacer(),
                if (appLimit.isEnabled)
                  TextButton.icon(
                    onPressed: () => _simulateBlock(appLimit),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Block'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addBlockedSection(AppLimit appLimit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Blocked Section for ${appLimit.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: appLimit.availableSections.map((section) {
            final isAlreadyBlocked = appLimit.blockedSections.contains(section);
            return ListTile(
              title: Text(section),
              trailing: isAlreadyBlocked
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: isAlreadyBlocked
                  ? null
                  : () {
                      setState(() {
                        appLimit.blockedSections.add(section);
                      });
                      _saveAppLimits();
                      Navigator.pop(context);
                    },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _simulateBlock(AppLimit appLimit) {
    showDialog(
      context: context,
      builder: (context) => MotivationalQuoteDialog(
        appName: appLimit.name,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  Future<bool> _showPermissionDialogAndRequest() async {
    final completer = Completer<bool>();
    
    if (!mounted) return false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To block apps, FocusFlow needs "Usage Access" permission.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('This allows the app to detect when blocked apps are opened.'),
              SizedBox(height: 16),
              Text(
                'Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Tap "Open Settings" below'),
              Text('2. Find "FocusFlow" in the list'),
              Text('3. Enable "Usage Access" toggle'),
              Text('4. Return to the app'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show instruction
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening settings...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              
              // Open settings immediately
              await AppBlockerService.requestUsageStatsPermission();
              
              // Also request overlay permission
              await AppBlockerService.requestPermissions();
              
              completer.complete(true);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    
    return completer.future;
  }

  void _showPermissionDialog() {
    _showPermissionDialogAndRequest();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How App Limits Work'),
        content: const Text(
          'App Limits help you stay focused by blocking distracting apps.\n\n'
          'When you try to open a blocked app, FocusFlow will immediately show a blocking screen with a motivational quote.\n\n'
          'Toggle the switch to enable/disable blocking for each app. You must grant Usage Access permission for this to work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
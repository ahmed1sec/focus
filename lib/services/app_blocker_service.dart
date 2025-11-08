import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class AppBlockerService {
  static const platform = MethodChannel('app_blocker');
  
  /// Check if usage stats permission is granted
  static Future<bool> hasUsageStatsPermission() async {
    try {
      final result = await platform.invokeMethod('hasUsageStatsPermission');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Request usage stats permission by opening settings
  static Future<void> requestUsageStatsPermission() async {
    try {
      await platform.invokeMethod('requestUsageStatsPermission');
    } catch (e) {
      print('Error requesting usage stats permission: $e');
      // Fallback: try to open app settings directly
      try {
        await ph.openAppSettings();
      } catch (e2) {
        print('Error opening app settings: $e2');
      }
    }
  }
  
  /// Open app settings directly
  static Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      return false;
    }
  }
  
  /// Request all required permissions for app blocking
  static Future<bool> requestPermissions() async {
    try {
      // Request system alert window permission first (shows dialog)
      final overlayStatus = await ph.Permission.systemAlertWindow.status;
      if (!overlayStatus.isGranted) {
        await ph.Permission.systemAlertWindow.request();
      }
      
      // Request notification permission for Android 13+
      if (await ph.Permission.notification.isDenied) {
        await ph.Permission.notification.request();
      }
      
      // Then open usage access settings (must be done manually)
      await requestUsageStatsPermission();
      
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      // Even if there's an error, try to open settings
      try {
        await requestUsageStatsPermission();
      } catch (_) {}
      return false;
    }
  }
  
  /// Start blocking the specified apps
  /// [blockedApps] should be a list of app names (e.g., ['YouTube', 'Instagram'])
  static Future<bool> startBlocking(List<String> blockedApps) async {
    try {
      if (blockedApps.isEmpty) {
        await stopBlocking();
        return true;
      }
      
      await platform.invokeMethod('startBlocking', blockedApps);
      return true;
    } catch (e) {
      print('Error starting app blocking: $e');
      return false;
    }
  }
  
  /// Stop blocking all apps
  static Future<void> stopBlocking() async {
    try {
      await platform.invokeMethod('stopBlocking');
    } catch (e) {
      print('Error stopping app blocking: $e');
    }
  }
  
  /// Check if blocking service is currently running
  static Future<bool> isBlocking() async {
    try {
      final result = await platform.invokeMethod('isBlocking');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking blocking status: $e');
      return false;
    }
  }
}
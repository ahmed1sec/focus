import 'package:flutter/material.dart';
import 'dart:convert';

class AppLimit {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> availableSections;
  List<String> blockedSections;
  bool isEnabled;
  int triggeredCount;

  AppLimit({
    required this.name,
    required this.icon,
    required this.color,
    required this.availableSections,
    this.blockedSections = const [],
    this.isEnabled = false,
    this.triggeredCount = 0,
  });

  static List<AppLimit> getDefaultApps() {
    return [
      AppLimit(
        name: 'Facebook',
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
        availableSections: ['News Feed', 'Stories', 'Reels', 'Marketplace', 'Groups'],
        blockedSections: [],
      ),
      AppLimit(
        name: 'YouTube',
        icon: Icons.play_circle_fill,
        color: const Color(0xFFFF0000),
        availableSections: ['Shorts', 'Trending', 'Subscriptions', 'Home Feed'],
        blockedSections: [],
      ),
      AppLimit(
        name: 'Instagram',
        icon: Icons.camera_alt,
        color: const Color(0xFFE4405F),
        availableSections: ['Stories', 'Reels', 'Explore', 'Home Feed'],
        blockedSections: [],
      ),
      AppLimit(
        name: 'TikTok',
        icon: Icons.music_note,
        color: const Color(0xFF000000),
        availableSections: ['For You', 'Following', 'Live', 'Discover'],
        blockedSections: [],
      ),
      AppLimit(
        name: 'Snapchat',
        icon: Icons.camera,
        color: const Color(0xFFFFFC00),
        availableSections: ['Stories', 'Discover', 'Snap Map', 'Chat'],
        blockedSections: [],
      ),
    ];
  }

  String toJson() {
    return json.encode({
      'name': name,
      'blockedSections': blockedSections,
      'isEnabled': isEnabled,
      'triggeredCount': triggeredCount,
    });
  }

  static AppLimit fromJson(String jsonString) {
    final data = json.decode(jsonString);
    final defaultApps = getDefaultApps();
    final defaultApp = defaultApps.firstWhere((app) => app.name == data['name']);
    
    return AppLimit(
      name: defaultApp.name,
      icon: defaultApp.icon,
      color: defaultApp.color,
      availableSections: defaultApp.availableSections,
      blockedSections: List<String>.from(data['blockedSections'] ?? []),
      isEnabled: data['isEnabled'] ?? false,
      triggeredCount: data['triggeredCount'] ?? 0,
    );
  }
}


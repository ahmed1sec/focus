import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool? getBool(String key) => _prefs?.getBool(key);
  static Future<bool> setBool(String key, bool value) async => 
      await _prefs?.setBool(key, value) ?? false;

  static String? getString(String key) => _prefs?.getString(key);
  static Future<bool> setString(String key, String value) async => 
      await _prefs?.setString(key, value) ?? false;

  static int? getInt(String key) => _prefs?.getInt(key);
  static Future<bool> setInt(String key, int value) async => 
      await _prefs?.setInt(key, value) ?? false;

  static List<String>? getStringList(String key) => _prefs?.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) async => 
      await _prefs?.setStringList(key, value) ?? false;

  static T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return fromJson(json.decode(jsonString));
    }
    return null;
  }

  static Future<bool> setObject<T>(String key, T object) async {
    final jsonString = json.encode(object);
    return await _prefs?.setString(key, jsonString) ?? false;
  }

  static Future<bool> remove(String key) async => 
      await _prefs?.remove(key) ?? false;
}
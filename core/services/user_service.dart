// lib/core/services/user_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static String? _cachedUserName;
  static SharedPreferences? _prefs;

  static Future<String> getUserName() async {
    // Return cached value if available
    if (_cachedUserName != null) {
      return _cachedUserName!;
    }

    try {
      // Get SharedPreferences instance (cache it too)
      _prefs ??= await SharedPreferences.getInstance();

      final userJson = _prefs!.getString('user');
      if (userJson != null) {
        final user = json.decode(userJson);
        _cachedUserName = user['name'] ?? 'User';
      } else {
        _cachedUserName = 'User';
      }

      return _cachedUserName!;
    } catch (e) {
      // Fallback on error
      _cachedUserName = 'User';
      return _cachedUserName!;
    }
  }

  // Clear cache when user data changes
  static void clearCache() {
    _cachedUserName = null;
  }

  // Update user name and cache
  static Future<void> updateUserName(String name) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      final userJson = _prefs!.getString('user');
      Map<String, dynamic> user = {};

      if (userJson != null) {
        user = json.decode(userJson);
      }

      user['name'] = name;
      await _prefs!.setString('user', json.encode(user));

      // Update cache
      _cachedUserName = name;
    } catch (e) {
      // Handle error silently or log it
    }
  }
}

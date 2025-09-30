// lib/core/utils/user_utils.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserUtils {
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      return json.decode(userData);
    }
    return {};
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aai_scanner_epson/core/services/user_service.dart';

class SessionManager {
  static bool? _cachedLoginStatus;
  static SharedPreferences? _prefs;

  static Future<bool> isLoggedIn() async {
    // Return cached value if available
    if (_cachedLoginStatus != null) {
      return _cachedLoginStatus!;
    }

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final token = _prefs!.getString('token');
      _cachedLoginStatus = token != null && token.isNotEmpty;
      return _cachedLoginStatus!;
    } catch (e) {
      _cachedLoginStatus = false;
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      // Remove session-related keys
      await Future.wait([
        _prefs!.remove('token'),
        _prefs!.remove('isLoggedIn'),
        _prefs!.remove('user'),
        _prefs!.remove('id'),
      ]);

      // Clear all caches
      _cachedLoginStatus = false;
      UserService.clearCache();
    } catch (e) {
      // Handle error but still clear caches
      _cachedLoginStatus = false;
      UserService.clearCache();
    }
  }

  // Call this when user successfully logs in
  static Future<void> setLoggedIn(String token) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('token', token);
      _cachedLoginStatus = true;
    } catch (e) {
      // Handle error
    }
  }

  // Clear cache when needed (e.g., token refresh)
  static void clearCache() {
    _cachedLoginStatus = null;
  }
}

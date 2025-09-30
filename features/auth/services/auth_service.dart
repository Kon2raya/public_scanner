import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<http.Response> postData(dynamic data, String apiUrl) async {
    final url = Uri.parse('$baseUrl/$apiUrl');
    return http.post(url, body: jsonEncode(data), headers: _defaultHeaders());
  }

  Future<dynamic> post(dynamic data, String apiUrl, {int? id}) async {
    try {
      final headers = await _authHeaders();
      final url = Uri.parse(
        id != null && id > 0 ? '$baseUrl/$apiUrl/$id' : '$baseUrl/$apiUrl',
      );

      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return 'Request failed with status: ${response.statusCode}.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<http.Response> getRecordById(String apiUrl, int id) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/$apiUrl/$id');
    return http.get(url, headers: headers);
  }

  Future<http.Response> getData(
    String apiUrl, {
    Map<String, dynamic>? params,
  }) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/$apiUrl').replace(
      queryParameters: params != null ? _stringifyParams(params) : null,
    );
    return http.get(url, headers: headers);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    return userData != null ? jsonDecode(userData) : null;
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Charset': 'utf-8',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _stringifyParams(Map<String, dynamic> params) {
    return params.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'Charset': 'utf-8',
  };
}

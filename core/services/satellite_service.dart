// lib/core/services/satellite_service.dart
import 'dart:convert';
import 'package:aai_scanner_epson/core/models/satellite.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';

class SatelliteService {
  static Future<List<Satellite>> fetchSatelliteList({
    required int userId,
    required String query,
  }) async {
    final authService = AuthService();
    final response = await authService.getData('users/$userId/satellites');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == true) {
        final options = List<dynamic>.from(res['data']);
        final satellites = options.map((e) => Satellite.fromJson(e)).toList();

        return satellites.where((satellite) {
          final codeMatch = satellite.satelliteCode.toLowerCase().contains(
            query.toLowerCase(),
          );
          final nameMatch = satellite.satelliteName.toLowerCase().contains(
            query.toLowerCase(),
          );
          return codeMatch || nameMatch;
        }).toList();
      }
    }
    throw Exception('Failed to fetch satellite options');
  }
}

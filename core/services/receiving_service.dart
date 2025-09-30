// lib/core/services/receiving_service.dart
import 'dart:convert';
import 'package:aai_scanner_epson/core/models/receiving.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';

class ReceivingService {
  static Future<List<Receiving>> fetchReceivingList({
    required int customerId,
    required int satelliteId,
    required String query,
  }) async {
    final authService = AuthService();
    final response = await authService.getData(
      'app_receiving',
      params: {'customer_id': customerId, 'satellite_id': satelliteId},
    );
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == true) {
        final options = List<dynamic>.from(res['data']);
        final receivings = options.map((e) => Receiving.fromJson(e)).toList();

        return receivings.where((receiving) {
          final rcvNoMatch = receiving.rcvNo.toLowerCase().contains(
            query.toLowerCase(),
          );
          return rcvNoMatch;
        }).toList();
      }
    }
    throw Exception('Failed to fetch receiving options');
  }
}

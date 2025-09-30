import 'dart:convert';
import 'package:aai_scanner_epson/core/models/receiving_header.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:aai_scanner_epson/core/models/receiving_payload_wrapper.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';

class ReceivingInfoService {
  static Future<ReceivingPayload> fetchReceivingInfo({
    required int rcvhdrId,
  }) async {
    final authService = AuthService();
    final response = await authService.getData(
      'app_receiving_info',
      params: {'rcvhdrId': rcvhdrId},
    );

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      if (res['status'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final header = ReceivingHeader.fromJson(data);

        final details = List<Map<String, dynamic>>.from(
          data['rcv_detail'] ?? [],
        );
        final items = details.map((e) => ReceivingItem.fromJson(e)).toList();
        return ReceivingPayload(header: header, details: items);
      }
    }

    throw Exception('Failed to fetch receiving info');
  }
}

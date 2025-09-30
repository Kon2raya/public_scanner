// lib/core/services/item_service.dart
import 'dart:convert';
import 'package:aai_scanner_epson/core/models/item.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';

class ItemService {
  static Future<List<Item>> fetchItemsByReceiving({
    required int rcvhdrId,
    required String query,
  }) async {
    final authService = AuthService();
    final response = await authService.getData(
      'app_receiving_item',
      params: {'rcvhdrId': rcvhdrId},
    );
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == true) {
        final options = List<dynamic>.from(res['data']);
        final items = options.map((e) => Item.fromJson(e)).toList();

        return items.where((item) {
          final codeMatch = item.itemCode.toLowerCase().contains(
            query.toLowerCase(),
          );
          final nameMatch = item.itemDescription.toLowerCase().contains(
            query.toLowerCase(),
          );
          return codeMatch || nameMatch;
        }).toList();
      }
    }
    throw Exception('Failed to fetch item options');
  }
}

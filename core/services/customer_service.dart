// lib/core/services/customer_service.dart
import 'dart:convert';
import 'package:aai_scanner_epson/core/models/customer.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';

class CustomerService {
  static Future<List<Customer>> fetchCustomerList({
    required int userId,
    required String query,
  }) async {
    final authService = AuthService();
    final response = await authService.getData('users/$userId/customers');
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == true) {
        final options = List<dynamic>.from(res['data']);
        final customers = options.map((e) => Customer.fromJson(e)).toList();

        return customers.where((customer) {
          final codeMatch = customer.customerCode.toLowerCase().contains(
            query.toLowerCase(),
          );
          final nameMatch = customer.customerName.toLowerCase().contains(
            query.toLowerCase(),
          );
          return codeMatch || nameMatch;
        }).toList();
      }
    }
    throw Exception('Failed to fetch customer options');
  }
}

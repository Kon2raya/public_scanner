import 'package:aai_scanner_epson/core/models/receiving_header.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';

class ReceivingPayload {
  final ReceivingHeader header;
  final List<ReceivingItem> details;

  ReceivingPayload({required this.header, required this.details});
}

// lib/core/notifiers/receiving_notifier.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/models/receiving.dart';

class ReceivingNotifier {
  static final ValueNotifier<Receiving?> selectedReceiving = ValueNotifier(
    null,
  );
}

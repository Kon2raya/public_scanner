// lib/core/routes/route_manager.dart
import 'package:aai_scanner_epson/features/palletizing/presentation/screens/palletizing_entry_screen.dart';
import 'package:aai_scanner_epson/features/receiving/presentation/screens/inbound_workflow_screens.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/inbound_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/features/auth/presentation/screens/login_screen.dart';
import 'package:aai_scanner_epson/features/home/presentation/screens/main_screen.dart';

class RouteManager {
  static const String login = '/login';
  static const String main = '/main';
  static const String inboundWorkflow = '/inbound-workflow';
  static const String inboundScanEnty = '/inbound-scan-entry';
  static const String palletizingEntry = '/palletizing-entry';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case inboundWorkflow:
        return MaterialPageRoute(builder: (_) => const InboundWorkflowScreen());
      case inboundScanEnty:
        return MaterialPageRoute(builder: (_) => const InboundEntryScreen());
      case palletizingEntry:
        return MaterialPageRoute(
          builder: (_) => const PalletizingEntryScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }
}

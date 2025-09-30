// lib/core/config/drawer_config.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/routes/route_manager.dart';

class DrawerItem {
  final IconData icon;
  final String label;
  final String? route;
  final List<DrawerItem>? children;

  const DrawerItem({
    required this.icon,
    required this.label,
    this.route,
    this.children,
  });
}

class DrawerConfig {
  static const List<DrawerItem> items = [
    DrawerItem(
      icon: Icons.pallet,
      label: 'Palletizing',
      route: RouteManager.palletizingEntry,
    ),
    DrawerItem(
      icon: Icons.move_to_inbox,
      label: 'Receiving',
      route: RouteManager.inboundScanEnty,
      // children: [
      //   DrawerItem(
      //     icon: Icons.arrow_right,
      //     label: 'Inbound',
      //     route: RouteManager.inboundScanEnty,
      //   ),
      // DrawerItem(
      //   icon: Icons.arrow_right,
      //   label: 'Midbound',
      //   route: RouteManager.midboundWorkflow,
      // ),
      // DrawerItem(
      //   icon: Icons.arrow_right,
      //   label: 'Outbound',
      //   route: RouteManager.outboundWorkflow,
      // ),
      // ],
    ),
    DrawerItem(
      icon: Icons.forklift,
      label: 'Putaway',
      route: RouteManager.inboundScanEnty,
    ),
    DrawerItem(
      icon: Icons.outbox_sharp,
      label: 'Dispatch',
      route: RouteManager.inboundScanEnty,
    ),
    DrawerItem(
      icon: Icons.table_chart_sharp,
      label: 'Countsheet',
      route: RouteManager.inboundScanEnty,
    ),
  ];
}

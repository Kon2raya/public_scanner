// lib/core/widgets/app_scaffold.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:flutter/material.dart';
import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final TabBar? tabBar;
  final int tabCount;
  final bool preventBack;
  final bool tabBarAtBottom;
  final bool enableBodyScrolling; // ✅ New flag to control scrolling

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.tabBar,
    this.tabCount = 0,
    this.preventBack = true,
    this.tabBarAtBottom = false,
    this.enableBodyScrolling =
        true, // ✅ Default: true for backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: actions,
        bottom: tabBarAtBottom ? null : tabBar,
      ),
      body: tabBar != null
          ? body
          : enableBodyScrolling
          ? SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: body,
            )
          : body, // ✅ Don't wrap in scroll if body manages its own scrolling
      bottomNavigationBar: tabBarAtBottom && tabBar != null
          ? Container(color: AppColors.primaryRed, child: tabBar!)
          : null,
    );

    final wrappedScaffold = preventBack
        ? PopScope(canPop: false, child: scaffold)
        : scaffold;

    return tabBar != null
        ? DefaultTabController(length: tabCount, child: wrappedScaffold)
        : wrappedScaffold;
  }
}

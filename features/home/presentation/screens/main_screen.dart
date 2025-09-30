import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Main Screen'),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
        ),
        drawer: Builder(
          builder: (context) => const AppDrawer(),
        ), // Lazy loading
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome to the Main Screen'),
              SizedBox(height: 20),
              Text('Use the drawer to navigate through the app.'),
            ],
          ),
        ),
      ),
    );
  }
}

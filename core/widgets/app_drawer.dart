// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/config/drawer_config.dart';
import 'package:aai_scanner_epson/core/services/user_service.dart';
import 'package:aai_scanner_epson/core/services/session_manager.dart';
import 'package:aai_scanner_epson/core/services/navigation_service.dart';
import 'package:aai_scanner_epson/core/utils/dialog_utils.dart';
import 'package:aai_scanner_epson/core/utils/string_extensions.dart';
import 'package:aai_scanner_epson/core/routes/route_manager.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final name = await UserService.getUserName().timeout(
        const Duration(seconds: 2),
      );

      if (mounted) {
        setState(() {
          userName = name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = 'User';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          ..._buildDrawerItems(),
          _buildLogoutTile(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: const BoxDecoration(color: AppColors.backgroundGrey),
      child: Column(
        children: [
          RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/logo/aai_logo_new.png',
                height: 50,
                cacheWidth: 200,
                cacheHeight: 60,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  userName.toPascalCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return DrawerConfig.items.map((item) {
      if (item.children != null && item.children!.isNotEmpty) {
        return ExpansionTile(
          leading: Icon(item.icon),
          title: Text(item.label),
          maintainState: false,
          children: item.children!.map((child) {
            return ListTile(
              leading: Icon(child.icon),
              title: Text(child.label),
              onTap: () => _handleNavigation(child.route),
            );
          }).toList(),
        );
      } else {
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.label),
          onTap: () => _handleNavigation(item.route),
        );
      }
    }).toList();
  }

  void _handleNavigation(String? route) {
    if (route != null) {
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.logout_outlined),
      title: const Text('Logout'),
      onTap: _handleLogout,
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await DialogUtils.showCustomDialog(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out?',
      actions: [
        DialogAction(label: 'Cancel', returnValue: false),
        DialogAction(
          label: 'Logout',
          returnValue: true,
          color: AppColors.primaryRed,
        ),
      ],
    );

    if (confirmed == true) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      await SessionManager.logout();
      NavigationService.replaceWith(RouteManager.login);
    }
  }
}

import 'package:aai_scanner_epson/core/routes/route_manager.dart';
import 'package:aai_scanner_epson/core/services/connectivity_service.dart';
import 'package:aai_scanner_epson/core/services/navigation_service.dart';
import 'package:aai_scanner_epson/core/services/session_manager.dart';
import 'package:aai_scanner_epson/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment
  await dotenv.load(fileName: ".env");

  // Initialize Hive in main.dart
  await Hive.initFlutter();
  // Set system UI mode with error handling
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (e) {
    // Continue if system UI setting fails
    AppLogger.info('Failed to set system UI mode: $e');
  }

  // Use timeout to prevent indefinite blocking
  String initialRoute = RouteManager.login;

  try {
    final connected = await ConnectivityService().isConnected().timeout(
      const Duration(seconds: 3),
    );

    if (!connected) {
      await SessionManager.logout();
    } else {
      final loggedIn = await SessionManager.isLoggedIn().timeout(
        const Duration(seconds: 2),
      );
      initialRoute = loggedIn
          ? RouteManager.inboundScanEnty
          : RouteManager.login;
    }
  } catch (e) {
    // If any operation times out or fails, default to login
    debugPrint('Startup check failed: $e');
    initialRoute = RouteManager.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'AAI WMS Scanner',
      theme: ThemeData(
        useMaterial3: true,
        // Add performance optimizations
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: RouteManager.generateRoute,
      // Add performance monitoring in debug mode
      builder: (context, child) {
        if (kDebugMode) {
          return Banner(
            message: 'DEBUG',
            location: BannerLocation.topEnd,
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}

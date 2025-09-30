import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void replaceWith(String routeName) {
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  static void goBack() {
    navigatorKey.currentState?.pop();
  }
}

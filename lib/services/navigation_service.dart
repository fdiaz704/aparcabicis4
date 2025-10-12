import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> pushNamedAndClearStack<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  // Platform-adaptive navigation methods
  static Future<T?> pushAdaptive<T extends Object?>(Widget page, {String? routeName}) {
    if (Platform.isIOS) {
      return navigatorKey.currentState!.push<T>(
        CupertinoPageRoute<T>(
          builder: (context) => page,
          settings: routeName != null ? RouteSettings(name: routeName) : null,
        ),
      );
    } else {
      return navigatorKey.currentState!.push<T>(
        MaterialPageRoute<T>(
          builder: (context) => page,
          settings: routeName != null ? RouteSettings(name: routeName) : null,
        ),
      );
    }
  }

  static Future<T?> pushReplacementAdaptive<T extends Object?, TO extends Object?>(
    Widget page, {
    String? routeName,
    TO? result,
  }) {
    if (Platform.isIOS) {
      return navigatorKey.currentState!.pushReplacement<T, TO>(
        CupertinoPageRoute<T>(
          builder: (context) => page,
          settings: routeName != null ? RouteSettings(name: routeName) : null,
        ),
        result: result,
      );
    } else {
      return navigatorKey.currentState!.pushReplacement<T, TO>(
        MaterialPageRoute<T>(
          builder: (context) => page,
          settings: routeName != null ? RouteSettings(name: routeName) : null,
        ),
        result: result,
      );
    }
  }

  static Future<T?> pushModalAdaptive<T extends Object?>(Widget page) {
    if (Platform.isIOS) {
      return navigatorKey.currentState!.push<T>(
        CupertinoPageRoute<T>(
          builder: (context) => page,
          fullscreenDialog: true,
        ),
      );
    } else {
      return navigatorKey.currentState!.push<T>(
        MaterialPageRoute<T>(
          builder: (context) => page,
          fullscreenDialog: true,
        ),
      );
    }
  }
}

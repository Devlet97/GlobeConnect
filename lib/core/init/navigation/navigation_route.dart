import 'package:flutter/material.dart';
import '../../../features/auth/view/auth_view.dart';
import '../../../features/home/view/home_view.dart';
import '../../../features/auth/view/register_view.dart';
import '../../../features/auth/view/forgot_password_view.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();
  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case '/':
      case '/auth':
        return _getRoute(const AuthView());
      case '/home':
        return _getRoute(const HomeView());
      case '/register':
        return _getRoute(const RegisterView());
      case '/forgot-password':
        return _getRoute(const ForgotPasswordView());
      default:
        return _getRoute(const AuthView());
    }
  }

  MaterialPageRoute _getRoute(Widget page) {
    return MaterialPageRoute(
      builder: (context) => page,
    );
  }
}

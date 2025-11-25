import 'package:flutter/material.dart';
// Zaktualizowane importy do folderu preview
import '../screens/admin/preview/menu_preview_screen.dart';
import '../screens/admin/preview/item_detail_preview_screen.dart';
import '../screens/admin/preview/info_preview_screen.dart';

import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_items_screen.dart';
import '../screens/admin/manage_categories_screen.dart';
import '../screens/admin/manage_notifications_screen.dart';
import '../screens/admin/settings_screen.dart';

class AppRoutes {
  // Public routes (teraz preview)
  static const String menu = '/';
  static const String itemDetail = '/item';
  static const String info = '/info';
  static const String notifications = '/notifications';

  // Admin routes
  static const String adminLogin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminItems = '/admin/items';
  static const String adminCategories = '/admin/categories';
  static const String adminNotifications = '/admin/notifications';
  static const String adminSettings = '/admin/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case menu:
        return _buildRoute(
          const MenuScreen(),
          settings: settings,
        );

      case itemDetail:
        if (args != null && args['itemId'] != null) {
          return _buildRoute(
            ItemDetailScreen(itemId: args['itemId']),
            settings: settings,
          );
        }
        return _errorRoute();

      case info:
        return _buildRoute(
          const InfoScreen(),
          settings: settings,
        );

      case adminLogin:
        return _buildRoute(
          const AdminLoginScreen(),
          settings: settings,
        );

      case adminDashboard:
        return _buildRoute(
          const AdminDashboardScreen(),
          settings: settings,
          requiresAuth: true,
        );

      case adminItems:
        return _buildRoute(
          const ManageItemsScreen(),
          settings: settings,
          requiresAuth: true,
        );

      case adminCategories:
        return _buildRoute(
          const ManageCategoriesScreen(),
          settings: settings,
          requiresAuth: true,
        );

      case adminNotifications:
        return _buildRoute(
          const ManageNotificationsScreen(),
          settings: settings,
          requiresAuth: true,
        );

      case adminSettings:
        return _buildRoute(
          const SettingsScreen(),
          settings: settings,
          requiresAuth: true,
        );

      default:
        return _errorRoute();
    }
  }

  static MaterialPageRoute _buildRoute(
      Widget page, {
        required RouteSettings settings,
        bool requiresAuth = false,
      }) {
    return MaterialPageRoute(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Page not found')),
        );
      },
    );
  }

  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    return Navigator.pushReplacementNamed<T, T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, String routeName, {Map<String, dynamic>? arguments, bool Function(Route<dynamic>)? predicate}) {
    return Navigator.pushNamedAndRemoveUntil<T>(context, routeName, predicate ?? (route) => false, arguments: arguments);
  }

  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}
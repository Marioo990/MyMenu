import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
// Fixed: Using alias for Category to avoid conflict with Flutter's Category annotation
import '../models/category.dart' as app_models;
import '../models/notification.dart';
import '../models/day_period.dart';
import '../services/firebase_service.dart';
import 'dart:async';

class MenuProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  // Data
  List<app_models.Category> _categories = [];
  List<MenuItem> _menuItems = [];
  List<RestaurantNotification> _notifications = [];
  List<DayPeriod> _dayPeriods = [];
  final List<StreamSubscription> _subscriptions = [];

  // Loading states
  bool _isLoadingCategories = false;
  bool _isLoadingItems = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingDayPeriods = false;

  // Error states
  String? _categoriesError;
  String? _itemsError;
  String? _notificationsError;
  String? _dayPeriodsError;

  // Getters
  List<app_models.Category> get categories => _categories;
  List<MenuItem> get menuItems => _menuItems;
  List<RestaurantNotification> get notifications => _notifications;
  List<DayPeriod> get dayPeriods => _dayPeriods;

  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingItems => _isLoadingItems;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isLoadingDayPeriods => _isLoadingDayPeriods;

  bool get isLoading => _isLoadingCategories || _isLoadingItems ||
      _isLoadingNotifications || _isLoadingDayPeriods;

  String? get categoriesError => _categoriesError;
  String? get itemsError => _itemsError;
  String? get notificationsError => _notificationsError;
  String? get dayPeriodsError => _dayPeriodsError;

  bool get hasError => _categoriesError != null || _itemsError != null ||
      _notificationsError != null || _dayPeriodsError != null;

  MenuProvider(this._firebaseService) {
    _initializeStreams();
  }

  // Initialize real-time streams
  void _initializeStreams() {
    print('📡 [MenuProvider] Inicjalizacja strumieni danych...');

    // Categories stream
    _subscriptions.add(
      _firebaseService.getCategoriesStream().listen(
            (categories) {
          print('✅ [MenuProvider] Pobrano ${categories.length} kategorii');
          _categories = categories;
          _categoriesError = null;
          notifyListeners();
        },
        onError: (error) {
          print('❌ [MenuProvider] Błąd pobierania kategorii: $error');
          // Jeśli błąd dotyczy indeksu, link pojawi się tutaj w konsoli
          _categoriesError = error.toString();
          notifyListeners();
        },
      ),
    );

    // Menu items stream
    _subscriptions.add(
      _firebaseService.getMenuItemsStream().listen(
            (items) {
          print('✅ [MenuProvider] Pobrano ${items.length} pozycji menu');
          _menuItems = items;
          _itemsError = null;
          notifyListeners();
        },
        onError: (error) {
          print('❌ [MenuProvider] Błąd pobierania menu: $error');
          _itemsError = error.toString();
          notifyListeners();
        },
      ),
    );

    // Notifications stream
    _subscriptions.add(
      _firebaseService.getNotificationsStream().listen(
            (notifications) {
          _notifications = notifications;
          _notificationsError = null;
          notifyListeners();
        },
        onError: (error) {
          _notificationsError = error.toString();
          notifyListeners();
        },
      ),
    );

    // Day periods stream
    _subscriptions.add(
      _firebaseService.getDayPeriodsStream().listen(
            (periods) {
          _dayPeriods = periods;
          _dayPeriodsError = null;
          notifyListeners();
        },
        onError: (error) {
          _dayPeriodsError = error.toString();
          notifyListeners();
        },
      ),
    );
  }

  // Load categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _firebaseService.getCategories();
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Load menu items
  Future<void> loadMenuItems({String? categoryId}) async {
    _isLoadingItems = true;
    _itemsError = null;
    notifyListeners();

    try {
      _menuItems = await _firebaseService.getMenuItems(categoryId: categoryId);
    } catch (e) {
      _itemsError = e.toString();
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  // Load day periods
  Future<void> loadDayPeriods() async {
    _isLoadingDayPeriods = true;
    _dayPeriodsError = null;
    notifyListeners();

    try {
      _dayPeriods = await _firebaseService.getDayPeriods();
    } catch (e) {
      _dayPeriodsError = e.toString();
    } finally {
      _isLoadingDayPeriods = false;
      notifyListeners();
    }
  }

  // Get active notifications
  Future<List<RestaurantNotification>> getActiveNotifications() async {
    try {
      return await _firebaseService.getActiveNotifications();
    } catch (e) {
      print('Error getting active notifications: $e');
      return [];
    }
  }

  // Get menu item by ID
  MenuItem? getMenuItem(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  app_models.Category? getCategory(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get items by category
  List<MenuItem> getItemsByCategory(String categoryId) {
    return _menuItems.where((item) => item.categoryId == categoryId).toList();
  }

  // Get items count by category
  int getItemsCountByCategory(String categoryId) {
    return getItemsByCategory(categoryId).length;
  }

  // Search menu items
  Future<List<MenuItem>> searchMenuItems(String query) async {
    if (query.isEmpty) {
      return _menuItems;
    }

    try {
      return await _firebaseService.searchMenuItems(query);
    } catch (e) {
      print('Error searching menu items: $e');
      return [];
    }
  }

  // Get filtered items
  List<MenuItem> getFilteredItems(MenuItemFilter filter, String locale) {
    return _menuItems.where((item) => filter.matches(item, locale)).toList();
  }

  // Sort items
  List<MenuItem> getSortedItems(List<MenuItem> items, MenuItemSort sort, String locale) {
    final sortedItems = List<MenuItem>.from(items);

    switch (sort) {
      case MenuItemSort.name:
        sortedItems.sort((a, b) => a.getName(locale).compareTo(b.getName(locale)));
        break;
      case MenuItemSort.priceAsc:
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case MenuItemSort.priceDesc:
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case MenuItemSort.calories:
        sortedItems.sort((a, b) {
          if (a.calories == null) return 1;
          if (b.calories == null) return -1;
          return a.calories!.compareTo(b.calories!);
        });
        break;
      case MenuItemSort.newest:
        sortedItems.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    return sortedItems;
  }

  // Get current day period
  DayPeriod? getCurrentDayPeriod() {
    return DayPeriod.getCurrentPeriod(_dayPeriods);
  }

  // Get items for current day period
  List<MenuItem> getItemsForCurrentDayPeriod() {
    final currentPeriod = getCurrentDayPeriod();
    if (currentPeriod == null) {
      return _menuItems;
    }

    return _menuItems.where((item) => item.isAvailableNow(currentPeriod.id)).toList();
  }

  // Admin functions (would be in separate admin provider in production)
  Future<void> createMenuItem(MenuItem item) async {
    try {
      await _firebaseService.createMenuItem(item);
      await loadMenuItems();
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      await _firebaseService.updateMenuItem(item);
      await loadMenuItems();
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _firebaseService.deleteMenuItem(id);
      await loadMenuItems();
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  Future<void> createCategory(app_models.Category category) async {
    try {
      await _firebaseService.createCategory(category);
      await loadCategories();
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(app_models.Category category) async {
    try {
      await _firebaseService.updateCategory(category);
      await loadCategories();
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firebaseService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> createNotification(RestaurantNotification notification) async {
    try {
      await _firebaseService.createNotification(notification);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  Future<void> updateNotification(RestaurantNotification notification) async {
    try {
      await _firebaseService.updateNotification(notification);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _firebaseService.deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadCategories(),
      loadMenuItems(),
      loadDayPeriods(),
    ]);
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
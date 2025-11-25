import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/menu_item.dart';
import '../models/category.dart' as app_models;
import '../models/notification.dart';
import '../models/day_period.dart';
import '../services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  String? _restaurantId;

  List<app_models.Category> _categories = [];
  List<MenuItem> _menuItems = [];
  List<RestaurantNotification> _notifications = [];
  List<DayPeriod> _dayPeriods = [];
  final List<StreamSubscription> _subscriptions = [];

  // Loading states (Separate to satisfy legacy code usage)
  bool _isLoadingCategories = false;
  bool _isLoadingItems = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingDayPeriods = false;

  // Combined loading getter
  bool get isLoading => _isLoadingCategories || _isLoadingItems || _isLoadingNotifications;

  // Legacy getters for UI compatibility
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingItems => _isLoadingItems;
  bool get isLoadingNotifications => _isLoadingNotifications;

  // Data getters
  List<app_models.Category> get categories => _categories;
  List<MenuItem> get menuItems => _menuItems;
  List<RestaurantNotification> get notifications => _notifications;
  List<DayPeriod> get dayPeriods => _dayPeriods;
  String? get restaurantId => _restaurantId;

  MenuProvider(this._firebaseService);

  void initData(String restaurantId) {
    if (_restaurantId == restaurantId) return;
    _restaurantId = restaurantId;
    _cancelSubscriptions();
    _initializeStreams(restaurantId);
  }

  void _initializeStreams(String restaurantId) {
    _isLoadingCategories = true;
    _isLoadingItems = true;
    _isLoadingNotifications = true;
    notifyListeners();

    _subscriptions.add(_firebaseService.getCategoriesStream(restaurantId).listen((data) {
      _categories = data;
      _isLoadingCategories = false;
      notifyListeners();
    }));

    _subscriptions.add(_firebaseService.getMenuItemsStream(restaurantId).listen((data) {
      _menuItems = data;
      _isLoadingItems = false;
      notifyListeners();
    }));

    _subscriptions.add(_firebaseService.getNotificationsStream(restaurantId).listen((data) {
      _notifications = data;
      _isLoadingNotifications = false;
      notifyListeners();
    }));

    _subscriptions.add(_firebaseService.getDayPeriodsStream(restaurantId).listen((data) {
      _dayPeriods = data;
      notifyListeners();
    }));
  }

  // Actions wrappers
  Future<void> createMenuItem(MenuItem item) async {
    if (_restaurantId == null) return;
    await _firebaseService.createMenuItem(item.copyWith(restaurantId: _restaurantId));
  }

  Future<void> updateMenuItem(MenuItem item) async => await _firebaseService.updateMenuItem(item);
  Future<void> deleteMenuItem(String id) async => await _firebaseService.deleteMenuItem(id);

  Future<void> createCategory(app_models.Category category) async {
    if (_restaurantId == null) return;
    await _firebaseService.createCategory(category.copyWith(restaurantId: _restaurantId));
  }
  Future<void> updateCategory(app_models.Category category) async => await _firebaseService.updateCategory(category);
  Future<void> deleteCategory(String id) async => await _firebaseService.deleteCategory(id);

  Future<void> createNotification(RestaurantNotification notification) async {
    if (_restaurantId == null) return;
    await _firebaseService.createNotification(notification, _restaurantId!);
  }
  Future<void> updateNotification(RestaurantNotification notification) async => await _firebaseService.updateNotification(notification);
  Future<void> deleteNotification(String id) async => await _firebaseService.deleteNotification(id);

  // Helpers
  MenuItem? getMenuItem(String id) => _menuItems.where((i) => i.id == id).firstOrNull;
  app_models.Category? getCategory(String id) => _categories.where((c) => c.id == id).firstOrNull;
  int getItemsCountByCategory(String catId) => _menuItems.where((i) => i.categoryId == catId).length;

  DayPeriod? getCurrentDayPeriod() => DayPeriod.getCurrentPeriod(_dayPeriods);

  Future<List<RestaurantNotification>> getActiveNotifications() async {
    if (_restaurantId == null) return [];
    return await _firebaseService.getActiveNotifications(_restaurantId!);
  }

  Future<void> refreshAll() async {
    if (_restaurantId != null) {
      _cancelSubscriptions();
      _initializeStreams(_restaurantId!);
    }
  }

  List<MenuItem> getSortedItems(List<MenuItem> items, MenuItemSort sort, String locale) {
    final sorted = List<MenuItem>.from(items);
    // Sorting logic implementation here if needed
    return sorted;
  }

  void _cancelSubscriptions() {
    for (var s in _subscriptions) s.cancel();
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
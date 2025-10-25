import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/notification.dart';
import '../models/day_period.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection = 'menuItems';
  static const String notificationsCollection = 'notifications';
  static const String dayPeriodsCollection = 'dayPeriods';
  static const String settingsCollection = 'settings';

  // Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }

  // Categories
  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<Category>> getCategories() async {
    final snapshot = await _firestore
        .collection(categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  Future<Category?> getCategory(String id) async {
    final doc = await _firestore
        .collection(categoriesCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return Category.fromFirestore(doc);
  }

  Future<void> createCategory(Category category) async {
    await _firestore
        .collection(categoriesCollection)
        .doc(category.id)
        .set(category.toFirestore());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore
        .collection(categoriesCollection)
        .doc(category.id)
        .update(category.toFirestore());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore
        .collection(categoriesCollection)
        .doc(id)
        .delete();
  }

  // Menu Items
  Stream<List<MenuItem>> getMenuItemsStream({String? categoryId}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(menuItemsCollection)
        .where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<MenuItem>> getMenuItems({String? categoryId}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(menuItemsCollection)
        .where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.orderBy('order').get();

    return snapshot.docs
        .map((doc) => MenuItem.fromFirestore(doc))
        .toList();
  }

  Future<MenuItem?> getMenuItem(String id) async {
    final doc = await _firestore
        .collection(menuItemsCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return MenuItem.fromFirestore(doc);
  }

  Future<void> createMenuItem(MenuItem item) async {
    await _firestore
        .collection(menuItemsCollection)
        .doc(item.id)
        .set(item.toFirestore());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _firestore
        .collection(menuItemsCollection)
        .doc(item.id)
        .update(item.toFirestore());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore
        .collection(menuItemsCollection)
        .doc(id)
        .delete();
  }

  // Search menu items
  Future<List<MenuItem>> searchMenuItems(String query) async {
    // Firestore doesn't support full-text search natively
    // For production, consider using Algolia or ElasticSearch
    // For now, we'll fetch all items and filter locally
    final items = await getMenuItems();
    final searchQuery = query.toLowerCase();

    return items.where((item) {
      final name = item.name.values.any((n) => n.toLowerCase().contains(searchQuery));
      final description = item.description.values.any((d) => d.toLowerCase().contains(searchQuery));
      return name || description;
    }).toList();
  }

  // Notifications
  Stream<List<RestaurantNotification>> getNotificationsStream() {
    final now = DateTime.now();
    return _firestore
        .collection(notificationsCollection)
        .where('endAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endAt')
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RestaurantNotification.fromFirestore(doc))
          .where((notification) => notification.isActive() || notification.isPending())
          .toList();
    });
  }

  Future<List<RestaurantNotification>> getActiveNotifications() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection(notificationsCollection)
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endAt')
        .orderBy('priority', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RestaurantNotification.fromFirestore(doc))
        .toList();
  }

  Future<void> createNotification(RestaurantNotification notification) async {
    await _firestore
        .collection(notificationsCollection)
        .doc(notification.id)
        .set(notification.toFirestore());
  }

  Future<void> updateNotification(RestaurantNotification notification) async {
    await _firestore
        .collection(notificationsCollection)
        .doc(notification.id)
        .update(notification.toFirestore());
  }

  Future<void> deleteNotification(String id) async {
    await _firestore
        .collection(notificationsCollection)
        .doc(id)
        .delete();
  }

  // Day Periods
  Stream<List<DayPeriod>> getDayPeriodsStream() {
    return _firestore
        .collection(dayPeriodsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DayPeriod.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<DayPeriod>> getDayPeriods() async {
    final snapshot = await _firestore
        .collection(dayPeriodsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => DayPeriod.fromFirestore(doc))
        .toList();
  }

  Future<void> createDayPeriod(DayPeriod period) async {
    await _firestore
        .collection(dayPeriodsCollection)
        .doc(period.id)
        .set(period.toFirestore());
  }

  Future<void> updateDayPeriod(DayPeriod period) async {
    await _firestore
        .collection(dayPeriodsCollection)
        .doc(period.id)
        .update(period.toFirestore());
  }

  Future<void> deleteDayPeriod(String id) async {
    await _firestore
        .collection(dayPeriodsCollection)
        .doc(id)
        .delete();
  }

  // Settings
  Stream<Map<String, dynamic>> getSettingsStream(String docId) {
    return _firestore
        .collection(settingsCollection)
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  Future<Map<String, dynamic>> getSettings(String docId) async {
    final doc = await _firestore
        .collection(settingsCollection)
        .doc(docId)
        .get();

    return doc.data() ?? {};
  }

  Future<void> updateSettings(String docId, Map<String, dynamic> data) async {
    await _firestore
        .collection(settingsCollection)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // Storage
  Future<String> uploadImage(String path, List<int> imageBytes) async {
    final ref = _storage.ref(path);
    final uploadTask = await ref.putData(
      imageBytes as dynamic,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteImage(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Batch operations
  Future<void> batchUpdateMenuItems(List<MenuItem> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      batch.update(
        _firestore.collection(menuItemsCollection).doc(item.id),
        item.toFirestore(),
      );
    }

    await batch.commit();
  }

  Future<void> batchDeleteMenuItems(List<String> itemIds) async {
    final batch = _firestore.batch();

    for (final id in itemIds) {
      batch.delete(
        _firestore.collection(menuItemsCollection).doc(id),
      );
    }

    await batch.commit();
  }

  // Export/Import
  Future<Map<String, dynamic>> exportData() async {
    final categories = await getCategories();
    final items = await getMenuItems();
    final periods = await getDayPeriods();
    final generalSettings = await getSettings('general');
    final menuVisibilitySettings = await getSettings('menuVisibility');
    final contactSettings = await getSettings('contact');

    return {
      'categories': categories.map((c) => c.toFirestore()).toList(),
      'menuItems': items.map((i) => i.toFirestore()).toList(),
      'dayPeriods': periods.map((p) => p.toFirestore()).toList(),
      'settings': {
        'general': generalSettings,
        'menuVisibility': menuVisibilitySettings,
        'contact': contactSettings,
      },
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final batch = _firestore.batch();

    // Import categories
    if (data['categories'] != null) {
      for (final categoryData in data['categories']) {
        final id = categoryData['id'] ?? _firestore.collection(categoriesCollection).doc().id;
        batch.set(
          _firestore.collection(categoriesCollection).doc(id),
          categoryData,
        );
      }
    }

    // Import menu items
    if (data['menuItems'] != null) {
      for (final itemData in data['menuItems']) {
        final id = itemData['id'] ?? _firestore.collection(menuItemsCollection).doc().id;
        batch.set(
          _firestore.collection(menuItemsCollection).doc(id),
          itemData,
        );
      }
    }

    // Import day periods
    if (data['dayPeriods'] != null) {
      for (final periodData in data['dayPeriods']) {
        final id = periodData['id'] ?? _firestore.collection(dayPeriodsCollection).doc().id;
        batch.set(
          _firestore.collection(dayPeriodsCollection).doc(id),
          periodData,
        );
      }
    }

    await batch.commit();

    // Import settings
    if (data['settings'] != null) {
      final settings = data['settings'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        await updateSettings(entry.key, entry.value);
      }
    }
  }
}
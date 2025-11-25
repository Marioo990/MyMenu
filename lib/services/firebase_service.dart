import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/notification.dart';
import '../models/day_period.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection = 'menuItems';
  static const String notificationsCollection = 'notifications';
  static const String dayPeriodsCollection = 'dayPeriods';
  static const String settingsCollection = 'settings';

  Future<void> enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }

  // --- SETTINGS (Scoped to Restaurant) ---

  Stream<Map<String, dynamic>> getSettingsStream(String restaurantId, String docId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection(settingsCollection)
        .doc(docId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<Map<String, dynamic>> getSettings(String restaurantId, String docId) async {
    final doc = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection(settingsCollection)
        .doc(docId)
        .get();
    return doc.data() ?? {};
  }

  Future<void> updateSettings(String restaurantId, String docId, Map<String, dynamic> data) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection(settingsCollection)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // --- KATEGORIE ---

  Stream<List<Category>> getCategoriesStream(String restaurantId) {
    return _firestore
        .collection(categoriesCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<void> createCategory(Category category) async {
    if (category.restaurantId.isEmpty) throw Exception('RestaurantID missing');
    await _firestore.collection(categoriesCollection).doc(category.id).set(category.toFirestore());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore.collection(categoriesCollection).doc(category.id).update(category.toFirestore());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(categoriesCollection).doc(id).delete();
  }

  // --- MENU ITEMS ---

  Stream<List<MenuItem>> getMenuItemsStream(String restaurantId, {String? categoryId}) {
    Query query = _firestore
        .collection(menuItemsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.orderBy('order').snapshots().map((snapshot) => snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList());
  }

  Future<List<MenuItem>> getMenuItems(String restaurantId, {String? categoryId}) async {
    Query query = _firestore.collection(menuItemsCollection).where('restaurantId', isEqualTo: restaurantId);
    if (categoryId != null) query = query.where('categoryId', isEqualTo: categoryId);

    final snap = await query.orderBy('order').get();
    return snap.docs.map((d) => MenuItem.fromFirestore(d)).toList();
  }

  Future<void> createMenuItem(MenuItem item) async {
    if (item.restaurantId.isEmpty) throw Exception('RestaurantID missing');
    await _firestore.collection(menuItemsCollection).doc(item.id).set(item.toFirestore());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _firestore.collection(menuItemsCollection).doc(item.id).update(item.toFirestore());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection(menuItemsCollection).doc(id).delete();
  }

  // --- NOTIFICATIONS ---

  Stream<List<RestaurantNotification>> getNotificationsStream(String restaurantId) {
    return _firestore
        .collection(notificationsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RestaurantNotification.fromFirestore(doc)).toList());
  }

  Future<List<RestaurantNotification>> getActiveNotifications(String restaurantId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection(notificationsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .where('endAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endAt')
        .get();

    return snapshot.docs
        .map((doc) => RestaurantNotification.fromFirestore(doc))
        .where((n) => n.startAt.isBefore(now))
        .toList();
  }

  Future<void> createNotification(RestaurantNotification notification, String restaurantId) async {
    final data = notification.toFirestore();
    data['restaurantId'] = restaurantId;
    await _firestore.collection(notificationsCollection).doc(notification.id).set(data);
  }

  Future<void> updateNotification(RestaurantNotification notification) async {
    await _firestore.collection(notificationsCollection).doc(notification.id).update(notification.toFirestore());
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection(notificationsCollection).doc(id).delete();
  }

  // --- DAY PERIODS ---

  Stream<List<DayPeriod>> getDayPeriodsStream(String restaurantId) {
    return _firestore
        .collection(dayPeriodsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DayPeriod.fromFirestore(doc)).toList());
  }

  Future<List<DayPeriod>> getDayPeriods(String restaurantId) async {
    final snap = await _firestore.collection(dayPeriodsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('order').get();
    return snap.docs.map((d) => DayPeriod.fromFirestore(d)).toList();
  }

  // --- STORAGE ---

  Future<String> uploadImage(String restaurantId, String fileName, Uint8List imageBytes) async {
    final path = 'restaurants/$restaurantId/items/$fileName';
    final ref = _storage.ref(path);
    final task = await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    return await task.ref.getDownloadURL();
  }

  // --- SEARCH ---

  Future<List<MenuItem>> searchMenuItems(String restaurantId, String query) async {
    // Simple client-side search due to Firestore limitations
    final items = await getMenuItems(restaurantId);
    final q = query.toLowerCase();
    return items.where((i) =>
        i.name.values.any((v) => v.toLowerCase().contains(q))
    ).toList();
  }

  // --- EXPORT / IMPORT ---

  Future<Map<String, dynamic>> exportData(String restaurantId) async {
    final items = await getMenuItems(restaurantId);
    final categories = await _firestore.collection(categoriesCollection).where('restaurantId', isEqualTo: restaurantId).get();

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'menuItems': items.map((i) => i.toFirestore()).toList(),
      'categories': categories.docs.map((d) => d.data()).toList(),
    };
  }

  Future<void> importData(String restaurantId, Map<String, dynamic> data) async {
    // Basic import implementation
    final batch = _firestore.batch();

    if (data['menuItems'] != null) {
      for (var itemData in (data['menuItems'] as List)) {
        itemData['restaurantId'] = restaurantId; // Ensure ID override
        final docRef = _firestore.collection(menuItemsCollection).doc();
        batch.set(docRef, itemData);
      }
    }

    await batch.commit();
  }
}
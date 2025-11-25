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

  // Collections
  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection = 'menuItems';
  static const String notificationsCollection = 'notifications';
  static const String dayPeriodsCollection = 'dayPeriods';
  static const String settingsCollection = 'settings'; // To może wymagać zmiany na subkolekcję w przyszłości

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

  // --- KATEGORIE (Scoped to Restaurant) ---

  Stream<List<Category>> getCategoriesStream(String restaurantId) {
    return _firestore
        .collection(categoriesCollection)
        .where('restaurantId', isEqualTo: restaurantId) // FILTRACJA
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    });
  }

  // --- MENU ITEMS (Scoped to Restaurant) ---

  Stream<List<MenuItem>> getMenuItemsStream(String restaurantId, {String? categoryId}) {
    Query query = _firestore
        .collection(menuItemsCollection)
        .where('restaurantId', isEqualTo: restaurantId) // FILTRACJA
        .where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  // Metoda tworzenia musi teraz wiedzieć o Restaurant ID
  // W modelach (MenuItem, Category) dodamy to pole w następnym kroku
  Future<void> createMenuItem(MenuItem item) async {
    if (item.restaurantId.isEmpty) throw Exception('RestaurantID is missing');
    await _firestore.collection(menuItemsCollection).doc(item.id).set(item.toFirestore());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _firestore.collection(menuItemsCollection).doc(item.id).update(item.toFirestore());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection(menuItemsCollection).doc(id).delete();
  }

  // ... (Reszta metod powinna być analogicznie zaktualizowana o parametr restaurantId)

  // --- STORAGE (Bez zmian, ale struktura plików może się zmienić) ---
  Future<String> uploadImage(String path, Uint8List imageBytes) async {
    final ref = _storage.ref(path);
    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }
}
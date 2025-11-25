import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/core/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Restaurant? _currentRestaurant;
  bool _isLoading = false;

  Restaurant? get currentRestaurant => _currentRestaurant;
  bool get isLoading => _isLoading;
  bool get hasRestaurant => _currentRestaurant != null;

  // Pobierz restaurację dla zalogowanego usera
  Future<void> loadRestaurantForUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Szukamy restauracji, gdzie ownerId == userId
      final snapshot = await _firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _currentRestaurant = Restaurant.fromFirestore(snapshot.docs.first);
      } else {
        _currentRestaurant = null;
      }
    } catch (e) {
      print('❌ Błąd ładowania restauracji: $e');
      _currentRestaurant = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Utwórz nową restaurację (Onboarding)
  Future<void> createRestaurant(String name, String currency) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany');

    _isLoading = true;
    notifyListeners();

    try {
      final docRef = _firestore.collection('restaurants').doc();

      final newRestaurant = Restaurant(
        id: docRef.id,
        ownerId: user.uid,
        name: name,
        currency: currency,
        createdAt: DateTime.now(),
      );

      await docRef.set(newRestaurant.toFirestore());
      _currentRestaurant = newRestaurant;

      print('✅ Utworzono restaurację: ${newRestaurant.name}');
    } catch (e) {
      print('❌ Błąd tworzenia restauracji: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _currentRestaurant = null;
    notifyListeners();
  }
}
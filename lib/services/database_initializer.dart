import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDatabase() async {
    print('🔧 Checking if database needs initialization...');

    try {
      // Check if settings already exist
      final generalDoc = await _firestore
          .collection('settings')
          .doc('general')
          .get();

      if (generalDoc.exists) {
        print('✅ Database already initialized');
        return;
      }

      print('🚀 Initializing database with default data...');

      // Initialize general settings
      await _firestore.collection('settings').doc('general').set({
        'restaurantName': {
          'en': 'My Restaurant',
          'pl': 'Moja Restauracja',
        },
        'activeLanguages': ['en', 'pl'],
        'defaultLanguage': 'en',
        'currency': 'USD',
        'dayPeriodsEnabled': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ General settings created');

      // Initialize menu visibility settings
      await _firestore.collection('settings').doc('menuVisibility').set({
        'showImages': true,
        'showThumbnails': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Menu visibility settings created');

      // Initialize contact settings
      await _firestore.collection('settings').doc('contact').set({
        'address': '',
        'phone': '',
        'email': '',
        'openingHours': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Contact settings created');

      // Create sample category
      await _firestore.collection('categories').doc('appetizers').set({
        'name': {
          'en': 'Appetizers',
          'pl': 'Przystawki',
        },
        'icon': '🥗',
        'order': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Sample category created');

      // Create sample menu item
      await _firestore.collection('menuItems').doc('sample-item-1').set({
        'name': {
          'en': 'Caesar Salad',
          'pl': 'Sałatka Caesar',
        },
        'description': {
          'en': 'Fresh romaine lettuce with parmesan cheese and croutons',
          'pl': 'Świeża sałata rzymska z serem parmezan i grzankami',
        },
        'price': 12.99,
        'categoryId': 'appetizers',
        'imageUrl': null,
        'calories': 350,
        'allergens': ['Gluten', 'Milk', 'Eggs'],
        'spiciness': 0,
        'dayPeriods': [],
        'tags': ['vegetarian'],
        'macros': {
          'protein': 15,
          'carbs': 25,
          'fat': 18,
        },
        'isActive': true,
        'order': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Sample menu item created');

      print('🎉 Database initialization complete!');
    } catch (e, stackTrace) {
      print('❌ Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> isDatabaseInitialized() async {
    try {
      final generalDoc = await _firestore
          .collection('settings')
          .doc('general')
          .get();
      return generalDoc.exists;
    } catch (e) {
      print('❌ Error checking database: $e');
      return false;
    }
  }
}
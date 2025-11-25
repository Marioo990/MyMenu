import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String ownerId;
  final String name;
  final String currency;
  final Map<String, dynamic> theme;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.currency,
    this.theme = const {},
    required this.createdAt,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      currency: data['currency'] ?? 'USD',
      theme: data['theme'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'currency': currency,
      'theme': theme,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
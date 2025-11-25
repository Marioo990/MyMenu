import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String restaurantId; // KLUCZOWE DLA SAAS
  final Map<String, String> name;
  final String? icon;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.icon,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: Map<String, String>.from(data['name'] ?? {}),
      icon: data['icon'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'icon': icon,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Category copyWith({
    String? id,
    String? restaurantId,
    Map<String, String>? name,
    String? icon,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getName(String locale) {
    return name[locale] ?? name['en'] ?? (name.values.isNotEmpty ? name.values.first : '');
  }

  String getDisplayIcon() {
    return icon ?? '🍴';
  }
}

class SpecialCategories {
  static const String favorites = 'favorites';
  static const String all = 'all';

  static Category getFavoritesCategory(Map<String, String> translations) {
    return Category(
      id: favorites,
      restaurantId: '',
      name: translations,
      icon: '❤️',
      order: -1,
      isActive: true,
    );
  }

  static Category getAllCategory(Map<String, String> translations) {
    return Category(
      id: all,
      restaurantId: '',
      name: translations,
      icon: '📜',
      order: -2,
      isActive: true,
    );
  }
}
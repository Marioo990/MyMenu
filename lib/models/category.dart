import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final Map<String, String> name;
  final String? icon;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      name: Map<String, String>.from(data['name'] ?? {}),
      icon: data['icon'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  Category copyWith({
    String? id,
    Map<String, String>? name,
    String? icon,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String getName(String locale) {
    return name[locale] ?? name['en'] ?? name.values.first;
  }

  String getDisplayIcon() {
    if (icon != null && icon!.isNotEmpty) {
      return icon!;
    }

    // Default icons based on common category names
    final firstNameValue = name.values.first.toLowerCase();
    if (firstNameValue.contains('appetizer') || firstNameValue.contains('przystawki')) {
      return '🥗';
    } else if (firstNameValue.contains('main') || firstNameValue.contains('główne')) {
      return '🍽️';
    } else if (firstNameValue.contains('dessert') || firstNameValue.contains('desery')) {
      return '🍰';
    } else if (firstNameValue.contains('drink') || firstNameValue.contains('napoje')) {
      return '🥤';
    } else if (firstNameValue.contains('soup') || firstNameValue.contains('zupy')) {
      return '🍲';
    } else if (firstNameValue.contains('salad') || firstNameValue.contains('sałatki')) {
      return '🥗';
    } else if (firstNameValue.contains('pizza')) {
      return '🍕';
    } else if (firstNameValue.contains('pasta') || firstNameValue.contains('makaron')) {
      return '🍝';
    } else if (firstNameValue.contains('burger')) {
      return '🍔';
    } else if (firstNameValue.contains('sandwich') || firstNameValue.contains('kanapki')) {
      return '🥪';
    } else if (firstNameValue.contains('breakfast') || firstNameValue.contains('śniadania')) {
      return '🍳';
    } else if (firstNameValue.contains('coffee') || firstNameValue.contains('kawa')) {
      return '☕';
    } else if (firstNameValue.contains('wine') || firstNameValue.contains('wino')) {
      return '🍷';
    } else if (firstNameValue.contains('beer') || firstNameValue.contains('piwo')) {
      return '🍺';
    } else if (firstNameValue.contains('cocktail') || firstNameValue.contains('koktajl')) {
      return '🍹';
    }

    return '🍴'; // Default icon
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Category &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Special categories
class SpecialCategories {
  static const String favorites = 'favorites';
  static const String all = 'all';

  static Category getFavoritesCategory(Map<String, String> translations) {
    return Category(
      id: favorites,
      name: translations,
      icon: '❤️',
      order: -1, // Always first
      isActive: true,
    );
  }

  static Category getAllCategory(Map<String, String> translations) {
    return Category(
      id: all,
      name: translations,
      icon: '📜',
      order: -2, // Always first after favorites
      isActive: true,
    );
  }
}
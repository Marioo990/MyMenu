import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final int? calories;
  final List<String> allergens;
  final int spiciness; // 0-3
  final List<String> dayPeriods;
  final List<String> tags;
  final Map<String, dynamic>? macros;
  final bool isActive;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.calories,
    this.allergens = const [],
    this.spiciness = 0,
    this.dayPeriods = const [],
    this.tags = const [],
    this.macros,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore
  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MenuItem(
      id: doc.id,
      name: Map<String, String>.from(data['name'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      calories: data['calories'],
      allergens: List<String>.from(data['allergens'] ?? []),
      spiciness: data['spiciness'] ?? 0,
      dayPeriods: List<String>.from(data['dayPeriods'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      macros: data['macros'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'calories': calories,
      'allergens': allergens,
      'spiciness': spiciness,
      'dayPeriods': dayPeriods,
      'tags': tags,
      'macros': macros,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  MenuItem copyWith({
    String? id,
    Map<String, String>? name,
    Map<String, String>? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    int? calories,
    List<String>? allergens,
    int? spiciness,
    List<String>? dayPeriods,
    List<String>? tags,
    Map<String, dynamic>? macros,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      spiciness: spiciness ?? this.spiciness,
      dayPeriods: dayPeriods ?? this.dayPeriods,
      tags: tags ?? this.tags,
      macros: macros ?? this.macros,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String getName(String locale) {
    return name[locale] ?? name['en'] ?? name.values.first;
  }

  String getDescription(String locale) {
    return description[locale] ?? description['en'] ?? description.values.first;
  }

  bool hasTag(String tag) {
    return tags.contains(tag);
  }

  bool isVegan() => hasTag('vegan');
  bool isVegetarian() => hasTag('vegetarian');
  bool isGlutenFree() => hasTag('gluten-free');
  bool isDairyFree() => hasTag('dairy-free');
  bool isSpicy() => spiciness > 0;

  String getSpicinessEmoji() {
    switch (spiciness) {
      case 1:
        return '🌶️';
      case 2:
        return '🌶️🌶️';
      case 3:
        return '🌶️🌶️🌶️';
      default:
        return '';
    }
  }

  List<String> getDietaryIcons() {
    final icons = <String>[];
    if (isVegan()) icons.add('🌱');
    if (isVegetarian()) icons.add('🥗');
    if (isGlutenFree()) icons.add('🌾');
    if (hasTag('fish')) icons.add('🐟');
    if (hasTag('meat')) icons.add('🥩');
    return icons;
  }

  bool isAvailableNow(String? currentDayPeriod) {
    if (dayPeriods.isEmpty || currentDayPeriod == null) {
      return true;
    }
    return dayPeriods.contains(currentDayPeriod);
  }
}

// Sort options enum
enum MenuItemSort {
  name,
  priceAsc,
  priceDesc,
  calories,
  newest,
}

// Filter options
class MenuItemFilter {
  final List<String> tags;
  final List<String> allergens;
  final double? minPrice;
  final double? maxPrice;
  final int? maxCalories;
  final int? maxSpiciness;
  final String? searchQuery;
  final String? categoryId;
  final String? dayPeriod;

  MenuItemFilter({
    this.tags = const [],
    this.allergens = const [],
    this.minPrice,
    this.maxPrice,
    this.maxCalories,
    this.maxSpiciness,
    this.searchQuery,
    this.categoryId,
    this.dayPeriod,
  });

  bool matches(MenuItem item, String locale) {
    // Check tags
    if (tags.isNotEmpty && !tags.any((tag) => item.hasTag(tag))) {
      return false;
    }

    // Check allergens (exclude items with these allergens)
    if (allergens.isNotEmpty && allergens.any((allergen) => item.allergens.contains(allergen))) {
      return false;
    }

    // Check price range
    if (minPrice != null && item.price < minPrice!) return false;
    if (maxPrice != null && item.price > maxPrice!) return false;

    // Check calories
    if (maxCalories != null && item.calories != null && item.calories! > maxCalories!) {
      return false;
    }

    // Check spiciness
    if (maxSpiciness != null && item.spiciness > maxSpiciness!) {
      return false;
    }

    // Check search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final name = item.getName(locale).toLowerCase();
      final description = item.getDescription(locale).toLowerCase();

      if (!name.contains(query) && !description.contains(query)) {
        return false;
      }
    }

    // Check category
    if (categoryId != null && item.categoryId != categoryId) {
      return false;
    }

    // Check day period
    if (dayPeriod != null && !item.isAvailableNow(dayPeriod)) {
      return false;
    }

    return true;
  }

  MenuItemFilter copyWith({
    List<String>? tags,
    List<String>? allergens,
    double? minPrice,
    double? maxPrice,
    int? maxCalories,
    int? maxSpiciness,
    String? searchQuery,
    String? categoryId,
    String? dayPeriod,
  }) {
    return MenuItemFilter(
      tags: tags ?? this.tags,
      allergens: allergens ?? this.allergens,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxCalories: maxCalories ?? this.maxCalories,
      maxSpiciness: maxSpiciness ?? this.maxSpiciness,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      dayPeriod: dayPeriod ?? this.dayPeriod,
    );
  }
}
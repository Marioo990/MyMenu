import 'package:cloud_firestore/cloud_firestore.dart';

enum MenuItemSort {
  name,
  priceAsc,
  priceDesc,
  calories,
  newest,
}

class MenuItem {
  final String id;
  final String restaurantId;
  final Map<String, String> name;
  final Map<String, String> description;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final int? calories;
  final List<String> allergens;
  final int spiciness; // 0-3

  // SMART MENU: Zastępuje stare dayPeriods
  final List<String> availabilityIds;
  final String? specialEventId;

  final List<String> tags;
  final Map<String, dynamic>? macros;
  final bool isActive;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.calories,
    this.allergens = const [],
    this.spiciness = 0,
    this.availabilityIds = const [],
    this.specialEventId,
    this.tags = const [],
    this.macros,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MenuItem(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: Map<String, String>.from(data['name'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      calories: data['calories'],
      allergens: List<String>.from(data['allergens'] ?? []),
      spiciness: data['spiciness'] ?? 0,
      availabilityIds: List<String>.from(data['availabilityIds'] ?? data['dayPeriods'] ?? []),
      specialEventId: data['specialEventId'],
      tags: List<String>.from(data['tags'] ?? []),
      macros: data['macros'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'calories': calories,
      'allergens': allergens,
      'spiciness': spiciness,
      'availabilityIds': availabilityIds,
      'specialEventId': specialEventId,
      'tags': tags,
      'macros': macros,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    Map<String, String>? name,
    Map<String, String>? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    int? calories,
    List<String>? allergens,
    int? spiciness,
    List<String>? availabilityIds,
    String? specialEventId,
    List<String>? tags,
    Map<String, dynamic>? macros,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      spiciness: spiciness ?? this.spiciness,
      availabilityIds: availabilityIds ?? this.availabilityIds,
      specialEventId: specialEventId ?? this.specialEventId,
      tags: tags ?? this.tags,
      macros: macros ?? this.macros,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getName(String locale) => name[locale] ?? name['en'] ?? (name.values.isNotEmpty ? name.values.first : '');
  String getDescription(String locale) => description[locale] ?? description['en'] ?? (description.values.isNotEmpty ? description.values.first : '');

  bool hasTag(String tag) => tags.any((t) => t.toLowerCase().trim() == tag.toLowerCase().trim());
  bool isVegan() => hasTag('vegan');
  bool isVegetarian() => hasTag('vegetarian');
  bool isGlutenFree() => hasTag('gluten-free');
  bool isDairyFree() => hasTag('dairy-free');
  bool isSpicy() => spiciness > 0;

  String getSpicinessEmoji() {
    if (spiciness == 1) return '🌶️';
    if (spiciness == 2) return '🌶️🌶️';
    if (spiciness >= 3) return '🌶️🌶️🌶️';
    return '';
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

  bool isAvailableNow(String? currentAvailabilityId) {
    if (availabilityIds.isEmpty || currentAvailabilityId == null) return true;
    return availabilityIds.contains(currentAvailabilityId);
  }
}

class MenuItemFilter {
  final List<String> tags;
  final List<String> allergens;
  final double? minPrice;
  final double? maxPrice;
  final int? maxCalories;
  final int? maxSpiciness;
  final String? searchQuery;
  final String? categoryId;
  final String? availabilityId;

  MenuItemFilter({
    this.tags = const [],
    this.allergens = const [],
    this.minPrice,
    this.maxPrice,
    this.maxCalories,
    this.maxSpiciness,
    this.searchQuery,
    this.categoryId,
    this.availabilityId,
  });

  bool matches(MenuItem item, String locale) {
    if (tags.isNotEmpty && !tags.every((tag) => item.hasTag(tag))) return false;
    if (allergens.isNotEmpty && allergens.any((allergen) => item.allergens.contains(allergen))) return false;
    if (minPrice != null && item.price < minPrice!) return false;
    if (maxPrice != null && item.price > maxPrice!) return false;
    if (maxCalories != null && item.calories != null && item.calories! > maxCalories!) return false;
    if (maxSpiciness != null && item.spiciness > maxSpiciness!) return false;
    if (categoryId != null && item.categoryId != categoryId) return false;
    if (availabilityId != null && !item.isAvailableNow(availabilityId)) return false;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final name = item.getName(locale).toLowerCase();
      final description = item.getDescription(locale).toLowerCase();
      if (!name.contains(query) && !description.contains(query)) return false;
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
    String? availabilityId,
    bool forceResetMinPrice = false,
    bool forceResetMaxPrice = false,
    bool forceResetCalories = false,
    bool forceResetSpiciness = false,
  }) {
    return MenuItemFilter(
      tags: tags ?? this.tags,
      allergens: allergens ?? this.allergens,
      minPrice: forceResetMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: forceResetMaxPrice ? null : (maxPrice ?? this.maxPrice),
      maxCalories: forceResetCalories ? null : (maxCalories ?? this.maxCalories),
      maxSpiciness: forceResetSpiciness ? null : (maxSpiciness ?? this.maxSpiciness),
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      availabilityId: availabilityId ?? this.availabilityId,
    );
  }
}
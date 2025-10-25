import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantNotification {
  final String id;
  final Map<String, String> title;
  final Map<String, String> message;
  final String? imageUrl;
  final String? ctaText;
  final String? deepLink;
  final DateTime startAt;
  final DateTime endAt;
  final int priority;
  final bool showAsBanner;
  final bool showInTab;
  final bool pin;
  final List<String> topics;
  final List<String> categories;
  final List<String> locales;
  final bool webPush;
  final bool inApp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestaurantNotification({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    this.ctaText,
    this.deepLink,
    required this.startAt,
    required this.endAt,
    this.priority = 0,
    this.showAsBanner = true,
    this.showInTab = true,
    this.pin = false,
    this.topics = const [],
    this.categories = const [],
    this.locales = const [],
    this.webPush = true,
    this.inApp = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore
  factory RestaurantNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RestaurantNotification(
      id: doc.id,
      title: Map<String, String>.from(data['title'] ?? {}),
      message: Map<String, String>.from(data['message'] ?? {}),
      imageUrl: data['imageUrl'],
      ctaText: data['ctaText'],
      deepLink: data['deepLink'],
      startAt: (data['startAt'] as Timestamp).toDate(),
      endAt: (data['endAt'] as Timestamp).toDate(),
      priority: data['priority'] ?? 0,
      showAsBanner: data['showAsBanner'] ?? true,
      showInTab: data['showInTab'] ?? true,
      pin: data['pin'] ?? false,
      topics: List<String>.from(data['topics'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      locales: List<String>.from(data['locales'] ?? []),
      webPush: data['webPush'] ?? true,
      inApp: data['inApp'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'ctaText': ctaText,
      'deepLink': deepLink,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'priority': priority,
      'showAsBanner': showAsBanner,
      'showInTab': showInTab,
      'pin': pin,
      'topics': topics,
      'categories': categories,
      'locales': locales,
      'webPush': webPush,
      'inApp': inApp,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  RestaurantNotification copyWith({
    String? id,
    Map<String, String>? title,
    Map<String, String>? message,
    String? imageUrl,
    String? ctaText,
    String? deepLink,
    DateTime? startAt,
    DateTime? endAt,
    int? priority,
    bool? showAsBanner,
    bool? showInTab,
    bool? pin,
    List<String>? topics,
    List<String>? categories,
    List<String>? locales,
    bool? webPush,
    bool? inApp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      ctaText: ctaText ?? this.ctaText,
      deepLink: deepLink ?? this.deepLink,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      priority: priority ?? this.priority,
      showAsBanner: showAsBanner ?? this.showAsBanner,
      showInTab: showInTab ?? this.showInTab,
      pin: pin ?? this.pin,
      topics: topics ?? this.topics,
      categories: categories ?? this.categories,
      locales: locales ?? this.locales,
      webPush: webPush ?? this.webPush,
      inApp: inApp ?? this.inApp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String getTitle(String locale) {
    return title[locale] ?? title['en'] ?? title.values.first;
  }

  String getMessage(String locale) {
    return message[locale] ?? message['en'] ?? message.values.first;
  }

  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  bool isPending() {
    return DateTime.now().isBefore(startAt);
  }

  bool isExpired() {
    return DateTime.now().isAfter(endAt);
  }

  bool shouldShowForLocale(String locale) {
    if (locales.isEmpty) return true;
    return locales.contains(locale);
  }

  bool shouldShowForCategory(String? categoryId) {
    if (categories.isEmpty || categoryId == null) return true;
    return categories.contains(categoryId);
  }

  bool shouldShowForTopics(List<String> userTopics) {
    if (topics.isEmpty) return true;
    return topics.any((topic) => userTopics.contains(topic));
  }

  // Deep link parsing
  DeepLinkData? parseDeepLink() {
    if (deepLink == null || deepLink!.isEmpty) return null;

    final uri = Uri.tryParse(deepLink!);
    if (uri == null) return null;

    if (uri.path.startsWith('/category/')) {
      final categoryId = uri.path.substring('/category/'.length);
      return DeepLinkData(type: DeepLinkType.category, id: categoryId);
    } else if (uri.path.startsWith('/item/')) {
      final itemId = uri.path.substring('/item/'.length);
      return DeepLinkData(type: DeepLinkType.item, id: itemId);
    } else if (uri.path == '/info') {
      return DeepLinkData(type: DeepLinkType.info, id: null);
    }

    return null;
  }
}

enum DeepLinkType {
  category,
  item,
  info,
}

class DeepLinkData {
  final DeepLinkType type;
  final String? id;

  DeepLinkData({
    required this.type,
    required this.id,
  });
}

// Notification status
enum NotificationStatus {
  active,
  pending,
  expired,
  dismissed,
}

// Sort options for notifications
enum NotificationSort {
  priority,
  startDate,
  endDate,
}
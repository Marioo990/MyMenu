class AppConstants {
  // App Info
  static const String appName = 'Restaurant Menu';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String googleClientId = '927400788077-your-client-id.apps.googleusercontent.com'; // Zaktualizuj jeśli masz właściwe ID

  // URLs
  static const String websiteUrl = 'https://restaurant.com';
  static const String privacyPolicyUrl = 'https://restaurant.com/privacy';
  static const String termsOfServiceUrl = 'https://restaurant.com/terms';
  static const String supportEmail = 'support@restaurant.com';

  // Firebase Collections
  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection = 'menuItems';
  static const String notificationsCollection = 'notifications';
  static const String dayPeriodsCollection = 'dayPeriods';
  static const String settingsCollection = 'settings';
  static const String usersCollection = 'users';
  static const String analyticsCollection = 'analytics';

  // Storage Paths
  static const String menuItemsStoragePath = 'menu_items';
  static const String categoriesStoragePath = 'categories';
  static const String notificationsStoragePath = 'notifications';
  static const String restaurantStoragePath = 'restaurant';

  // Cache Keys
  static const String cacheKeyMenuItems = 'cache_menu_items';
  static const String cacheKeyCategories = 'cache_categories';
  static const String cacheKeySettings = 'cache_settings';
  static const String cacheKeyFavorites = 'favorites';
  static const String cacheKeyLanguage = 'selected_locale';

  // Limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 100;
  static const int maxNotificationTitleLength = 50;
  static const int maxNotificationMessageLength = 200;
  static const int itemsPerPage = 20;
  static const int maxFavorites = 100;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration sessionTimeout = Duration(hours: 2);
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'pl', 'de', 'es', 'fr'];
  static const String defaultLanguage = 'en';

  // Supported Currencies
  static const List<String> supportedCurrencies = ['USD', 'EUR', 'GBP', 'PLN'];
  static const String defaultCurrency = 'USD';

  // Dietary Tags
  static const List<String> dietaryTags = [
    'vegan',
    'vegetarian',
    'gluten-free',
    'dairy-free',
    'nut-free',
    'halal',
    'kosher',
    'low-carb',
    'keto',
    'high-protein',
    'fish',
    'meat',
    'spicy',
  ];

  // Common Allergens
  static const List<String> commonAllergens = [
    'Gluten',
    'Milk',
    'Eggs',
    'Fish',
    'Shellfish',
    'Tree nuts',
    'Peanuts',
    'Soy',
    'Sesame',
    'Mustard',
    'Celery',
    'Sulphites',
    'Lupin',
    'Molluscs',
  ];

  // Default Images
  static const String defaultMenuItemImage = 'assets/images/default_food.png';
  static const String defaultCategoryImage = 'assets/images/default_category.png';
  static const String defaultRestaurantLogo = 'assets/images/logo.png';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{7,15}$',
  );
  static final RegExp priceRegex = RegExp(
    r'^\d+(\.\d{1,2})?$',
  );

  // Error Messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorAuth = 'Authentication failed. Please sign in again.';
  static const String errorPermission = 'You do not have permission to perform this action.';
  static const String errorNotFound = 'The requested item was not found.';
  static const String errorInvalidInput = 'Please check your input and try again.';

  // Success Messages
  static const String successSaved = 'Changes saved successfully!';
  static const String successDeleted = 'Item deleted successfully!';
  static const String successUpdated = 'Updated successfully!';
  static const String successCreated = 'Created successfully!';
  static const String successCopied = 'Copied to clipboard!';

  // Notification Topics
  static const List<String> notificationTopics = [
    'all_users',
    'promotions',
    'new_items',
    'events',
    'updates',
  ];

  // Social Media URLs
  static const String facebookUrl = 'https://facebook.com/restaurant';
  static const String instagramUrl = 'https://instagram.com/restaurant';
  static const String twitterUrl = 'https://twitter.com/restaurant';
  static const String tiktokUrl = 'https://tiktok.com/@restaurant';
  static const String youtubeUrl = 'https://youtube.com/restaurant';

  // Map Constants
  static const double defaultMapZoom = 15.0;
  static const double defaultLatitude = 52.2297; // Warsaw
  static const double defaultLongitude = 21.0122;

  // PWA Constants
  static const String pwaName = 'Restaurant Menu';
  static const String pwaShortName = 'Menu';
  static const String pwaDescription = 'Digital restaurant menu with QR code access';
  static const String pwaThemeColor = '#2C3E50';
  static const String pwaBackgroundColor = '#f5f5f5';

  // QR Code
  static const String qrCodePrefix = 'https://menu.restaurant.com/';
  static const int qrCodeSize = 300;

  // Analytics Events
  static const String eventMenuViewed = 'menu_viewed';
  static const String eventItemViewed = 'item_viewed';
  static const String eventItemFavorited = 'item_favorited';
  static const String eventCategorySelected = 'category_selected';
  static const String eventSearchPerformed = 'search_performed';
  static const String eventFilterApplied = 'filter_applied';
  static const String eventNotificationOpened = 'notification_opened';
  static const String eventLanguageChanged = 'language_changed';
  static const String eventContactTapped = 'contact_tapped';
  static const String eventDirectionsRequested = 'directions_requested';

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableDayPeriods = true;
  static const bool enableMultiLanguage = true;
  static const bool enableFavorites = true;
  static const bool enableSearch = true;
  static const bool enableFilters = true;
  static const bool enableNotificationBanner = true;
  static const bool enableQrCode = true;

  // Development
  static const bool isDevelopment = false;
  static const bool showDebugBanner = false;
  static const String debugEmail = 'admin@test.com';
  static const String debugPassword = 'test123';
}
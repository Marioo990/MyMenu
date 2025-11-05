import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  // Supported locales - const to ensure compile-time constant
  static const List<Locale> _supportedLocales = [
    Locale('en'),  // Usunięto country code
    Locale('pl'),  // Usunięto 'PL'
    Locale('de'),  // Usunięto 'DE'
    Locale('es'),  // Usunięto 'ES'
    Locale('fr'),  // Usunięto 'FR'
  ];

  // CRITICAL: Always initialized with default value - never null
  Locale _currentLocale = const Locale('en');
  bool _isLoading = true;

  // Getters - guaranteed non-null
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  List<Locale> get supportedLocales => _supportedLocales;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    print('🌍 [LanguageProvider] Initializing with default locale: $_currentLocale');
    _loadSavedLocale();
  }

  // Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    try {
      print('🌍 [LanguageProvider] Loading saved locale...');
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        print('🌍 [LanguageProvider] Found saved locale: $savedLocaleCode');
        final locale = _supportedLocales.firstWhere(
              (locale) => locale.languageCode == savedLocaleCode,
          orElse: () => const Locale('en'),  // Usunięto 'US'
        );
        _currentLocale = locale;
      } else {
        print('🌍 [LanguageProvider] No saved locale, checking system locale...');
        // Try to use system locale
        _currentLocale = _getSystemLocale();
      }

      print('🌍 [LanguageProvider] Current locale set to: $_currentLocale');
    } catch (e) {
      print('❌ [LanguageProvider] Error loading saved locale: $e');
      // Keep default value - already set in initialization
      _currentLocale = const Locale('en', 'US');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('✅ [LanguageProvider] Initialization complete (locale: $_currentLocale)');
    }
  }

  // Get system locale if supported
  Locale _getSystemLocale() {
    try {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      print('🌍 [LanguageProvider] System locale: $systemLocale');

      // Check if system locale is supported
      final supportedLocale = _supportedLocales.firstWhere(
            (locale) => locale.languageCode == systemLocale.languageCode,
        orElse: () => const Locale('en', 'US'),
      );

      print('🌍 [LanguageProvider] Using locale: $supportedLocale');
      return supportedLocale;
    } catch (e) {
      print('⚠️ [LanguageProvider] Error getting system locale: $e');
      return const Locale('en', 'US');
    }
  }

  // Save locale to preferences
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      print('💾 [LanguageProvider] Saved locale: ${locale.languageCode}');
    } catch (e) {
      print('❌ [LanguageProvider] Error saving locale: $e');
    }
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    if (!_supportedLocales.contains(locale)) {
      print('⚠️ [LanguageProvider] Unsupported locale: $locale, using default');
      locale = const Locale('en', 'US');
    }

    print('🌍 [LanguageProvider] Setting locale to: $locale');
    _currentLocale = locale;
    await _saveLocale(locale);
    notifyListeners();
  }

  // Set locale by language code
  Future<void> setLanguageCode(String languageCode) async {
    print('🌍 [LanguageProvider] Setting language code: $languageCode');
    final locale = _supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'),
    );

    await setLocale(locale);
  }

  // Translations map
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'menu': 'Menu',
      'favorites': 'Favorites',
      'all': 'All',
      'search': 'Search',
      'search_menu': 'Search menu...',
      'search_hint': 'Search for dishes...',
      'tap_to_search': 'Tap to search',
      'filter': 'Filter',
      'sort': 'Sort',
      'price': 'Price',
      'price_low': 'Price: Low to High',
      'price_high': 'Price: High to Low',
      'price_range': 'Price Range',
      'calories': 'Calories',
      'max_calories': 'Max Calories',
      'name': 'Name',
      'newest': 'Newest',
      'contains_allergens': 'Contains allergens',
      'dietary': 'Dietary',
      'vegan': 'Vegan',
      'vegetarian': 'Vegetarian',
      'gluten_free': 'Gluten Free',
      'dairy_free': 'Dairy Free',
      'high_protein': 'High Protein',
      'low_carb': 'Low Carb',
      'fish': 'Fish',
      'meat': 'Meat',
      'spicy': 'Spicy',
      'spiciness': 'Spiciness',
      'mild': 'Mild',
      'medium': 'Medium',
      'hot': 'Hot',
      'very_hot': 'Very Hot',
      'ingredients': 'Ingredients',
      'nutrition': 'Nutrition',
      'protein': 'Protein',
      'carbs': 'Carbohydrates',
      'fat': 'Fat',
      'fiber': 'Fiber',
      'sugar': 'Sugar',
      'sodium': 'Sodium',
      'allergens': 'Allergens',
      'category': 'Category',
      'add_to_cart': 'Add to Cart',
      'view_details': 'View Details',
      'restaurant_info': 'Restaurant Info',
      'contact': 'Contact',
      'address': 'Address',
      'phone': 'Phone',
      'email': 'Email',
      'opening_hours': 'Opening Hours',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'closed': 'Closed',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications',
      'settings': 'Settings',
      'language': 'Language',
      'currency': 'Currency',
      'show_images': 'Show Images',
      'show_thumbnails': 'Show Thumbnails',
      'day_periods': 'Day Periods',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'no_items_found': 'No items found',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'clear': 'Clear',
      'apply': 'Apply',
      'admin': 'Admin',
      'admin_login': 'Admin Login',
      'admin_panel': 'Admin Panel',
      'admin_access_only': 'Admin access only',
      'login': 'Login',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'welcome_admin': 'Welcome, Admin!',
      'dashboard_subtitle': 'Manage your restaurant menu and settings',
      'quick_actions': 'Quick Actions',
      'total_items': 'Total Items',
      'categories': 'Categories',
      'active_notifications': 'Active Notifications',
      'manage_menu': 'Manage Menu',
      'add_edit_delete_items': 'Add, edit, or delete menu items',
      'manage_categories': 'Manage Categories',
      'organize_menu_categories': 'Organize menu categories',
      'create_announcements': 'Create announcements',
      'configure_restaurant': 'Configure restaurant settings',
      'recent_activity': 'Recent Activity',
      'view_all': 'View All',
      'item_added': 'Item added',
      'category_updated': 'Category updated',
      'item_deleted': 'Item deleted',
      'notification_created': 'Notification created',
      'settings_changed': 'Settings changed',
      'save_settings': 'Save Settings',
      'email_required': 'Email is required',
      'invalid_email': 'Invalid email address',
      'password_required': 'Password is required',
      'password_too_short': 'Password must be at least 6 characters',
      'forgot_password': 'Forgot Password?',
      'reset_password_info': 'Enter your email to receive password reset instructions',
      'reset_email_sent': 'Password reset email sent',
      'send_reset_email': 'Send Reset Email',
      'admin_info': 'Only authorized personnel can access this area',
      'password': 'Password',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'are_you_sure': 'Are you sure?',
      'yes': 'Yes',
      'no': 'No',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'no_categories': 'No categories yet',
      'add_first_category': 'Add your first category',
      'edit': 'Edit',
      'active': 'Active',
      'inactive': 'Inactive',
      'activate': 'Activate',
      'deactivate': 'Deactivate',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'delete_category': 'Delete category',
      'category_deleted': 'Category deleted successfully',
      'items': 'items',
      'icon': 'Icon',
      'category_names': 'Category Names',
      'display_order': 'Display Order',
      'add_item': 'Add Item',
      'edit_item': 'Edit Item',
      'item_deleted': 'Item deleted successfully',
      'add_notification': 'Add Notification',
      'edit_notification': 'Edit Notification',
      'scheduled': 'Scheduled',
      'expired': 'Expired',
      'no_active_notifications': 'No active notifications',
      'no_scheduled_notifications': 'No scheduled notifications',
      'no_expired_notifications': 'No expired notifications',
      'pinned': 'Pinned',
      'notification_deleted': 'Notification deleted successfully',
      'show_as_banner': 'Show as Banner',
      'show_in_tab': 'Show in Tab',
      'pin_notification': 'Pin Notification',
      'description': 'Description',
      'follow_us': 'Follow Us',
      'about_us': 'About Us',
      'location': 'Location',
    },
    'pl': {
      'menu': 'Menu',
      'favorites': 'Ulubione',
      'all': 'Wszystkie',
      'search': 'Szukaj',
      'search_menu': 'Szukaj w menu...',
      'search_hint': 'Szukaj potraw...',
      'tap_to_search': 'Dotknij aby szukać',
      'filter': 'Filtruj',
      'sort': 'Sortuj',
      'price': 'Cena',
      'price_low': 'Cena: Od najtańszych',
      'price_high': 'Cena: Od najdroższych',
      'price_range': 'Zakres cen',
      'calories': 'Kalorie',
      'max_calories': 'Maks. kalorii',
      'name': 'Nazwa',
      'newest': 'Najnowsze',
      'contains_allergens': 'Zawiera alergeny',
      'dietary': 'Dietetyczne',
      'vegan': 'Wegańskie',
      'vegetarian': 'Wegetariańskie',
      'gluten_free': 'Bezglutenowe',
      'dairy_free': 'Bez laktozy',
      'high_protein': 'Wysokobiałkowe',
      'low_carb': 'Niskowęglowodanowe',
      'fish': 'Ryby',
      'meat': 'Mięso',
      'spicy': 'Ostre',
      'spiciness': 'Ostrość',
      'mild': 'Łagodne',
      'medium': 'Średnie',
      'hot': 'Ostre',
      'very_hot': 'Bardzo ostre',
      'ingredients': 'Składniki',
      'nutrition': 'Wartości odżywcze',
      'protein': 'Białko',
      'carbs': 'Węglowodany',
      'fat': 'Tłuszcz',
      'fiber': 'Błonnik',
      'sugar': 'Cukier',
      'sodium': 'Sód',
      'allergens': 'Alergeny',
      'category': 'Kategoria',
      'add_to_cart': 'Dodaj do koszyka',
      'view_details': 'Zobacz szczegóły',
      'restaurant_info': 'Informacje o restauracji',
      'contact': 'Kontakt',
      'address': 'Adres',
      'phone': 'Telefon',
      'email': 'Email',
      'opening_hours': 'Godziny otwarcia',
      'monday': 'Poniedziałek',
      'tuesday': 'Wtorek',
      'wednesday': 'Środa',
      'thursday': 'Czwartek',
      'friday': 'Piątek',
      'saturday': 'Sobota',
      'sunday': 'Niedziela',
      'closed': 'Zamknięte',
      'notifications': 'Powiadomienia',
      'no_notifications': 'Brak powiadomień',
      'settings': 'Ustawienia',
      'language': 'Język',
      'currency': 'Waluta',
      'show_images': 'Pokaż obrazy',
      'show_thumbnails': 'Pokaż miniatury',
      'day_periods': 'Pory dnia',
      'breakfast': 'Śniadanie',
      'lunch': 'Obiad',
      'dinner': 'Kolacja',
      'no_items_found': 'Nie znaleziono pozycji',
      'loading': 'Ładowanie...',
      'error': 'Błąd',
      'retry': 'Ponów',
      'clear': 'Wyczyść',
      'apply': 'Zastosuj',
      // ... rest of translations would be here
    },
  };

  // Get translation
  String translate(String key) {
    final languageCode = _currentLocale.languageCode;
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // Get translation with parameters
  String translateWithParams(String key, Map<String, dynamic> params) {
    var translation = translate(key);

    params.forEach((paramKey, paramValue) {
      translation = translation.replaceAll('{$paramKey}', paramValue.toString());
    });

    return translation;
  }

  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    return _supportedLocales.any((supportedLocale) =>
    supportedLocale.languageCode == locale.languageCode);
  }

  // Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'pl':
        return 'Polski';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return languageCode.toUpperCase();
    }
  }

  // Get current language name
  String get currentLanguageName => getLanguageName(_currentLocale.languageCode);

  // Get flag emoji for language
  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'pl':
        return '🇵🇱';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }

  // Get current language flag
  String get currentLanguageFlag => getLanguageFlag(_currentLocale.languageCode);

  // Check if current locale is RTL
  bool get isRTL {
    // Add RTL languages if needed
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(_currentLocale.languageCode);
  }

  // Get all available translations for a key
  Map<String, String> getTranslationsForKey(String key) {
    final translations = <String, String>{};

    _translations.forEach((languageCode, languageTranslations) {
      final translation = languageTranslations[key];
      if (translation != null) {
        translations[languageCode] = translation;
      }
    });

    return translations;
  }

  // Reset to default locale
  Future<void> resetToDefault() async {
    await setLocale(const Locale('en', 'US'));
  }
}
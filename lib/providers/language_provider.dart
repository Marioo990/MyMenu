import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  // Supported locales
  static const List<Locale> _supportedLocales = [
    Locale('en', 'US'),
    Locale('pl', 'PL'),
    Locale('de', 'DE'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];

  // Translations
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'menu': 'Menu',
      'favorites': 'Favorites',
      'all': 'All',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'price': 'Price',
      'calories': 'Calories',
      'name': 'Name',
      'newest': 'Newest',
      'contains_allergens': 'Contains allergens',
      'dietary': 'Dietary',
      'vegan': 'Vegan',
      'vegetarian': 'Vegetarian',
      'gluten_free': 'Gluten Free',
      'dairy_free': 'Dairy Free',
      'spicy': 'Spicy',
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
      'admin': 'Admin',
      'login': 'Login',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'manage_menu': 'Manage Menu',
      'manage_categories': 'Manage Categories',
      'manage_notifications': 'Manage Notifications',
      'add_item': 'Add Item',
      'edit_item': 'Edit Item',
      'delete_item': 'Delete Item',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'are_you_sure': 'Are you sure?',
      'yes': 'Yes',
      'no': 'No',
    },
    'pl': {
      'menu': 'Menu',
      'favorites': 'Ulubione',
      'all': 'Wszystkie',
      'search': 'Szukaj',
      'filter': 'Filtruj',
      'sort': 'Sortuj',
      'price': 'Cena',
      'calories': 'Kalorie',
      'name': 'Nazwa',
      'newest': 'Najnowsze',
      'contains_allergens': 'Zawiera alergeny',
      'dietary': 'Dietetyczne',
      'vegan': 'Wegańskie',
      'vegetarian': 'Wegetariańskie',
      'gluten_free': 'Bezglutenowe',
      'dairy_free': 'Bez laktozy',
      'spicy': 'Ostre',
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
      'admin': 'Administrator',
      'login': 'Zaloguj',
      'logout': 'Wyloguj',
      'dashboard': 'Panel',
      'manage_menu': 'Zarządzaj menu',
      'manage_categories': 'Zarządzaj kategoriami',
      'manage_notifications': 'Zarządzaj powiadomieniami',
      'add_item': 'Dodaj pozycję',
      'edit_item': 'Edytuj pozycję',
      'delete_item': 'Usuń pozycję',
      'save': 'Zapisz',
      'cancel': 'Anuluj',
      'confirm': 'Potwierdź',
      'are_you_sure': 'Czy na pewno?',
      'yes': 'Tak',
      'no': 'Nie',
    },
  };

  Locale _currentLocale = const Locale('en', 'US');
  bool _isLoading = false;

  // Getters
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  List<Locale> get supportedLocales => _supportedLocales;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _loadSavedLocale();
  }

  // Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        final locale = _supportedLocales.firstWhere(
              (locale) => locale.languageCode == savedLocaleCode,
          orElse: () => const Locale('en', 'US'),
        );
        _currentLocale = locale;
      } else {
        // Try to use system locale
        _currentLocale = _getSystemLocale();
      }
    } catch (e) {
      print('Error loading saved locale: $e');
      _currentLocale = const Locale('en', 'US');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get system locale if supported
  Locale _getSystemLocale() {
    final systemLocale = WidgetsBinding.instance.window.locale;

    // Check if system locale is supported
    final supportedLocale = _supportedLocales.firstWhere(
          (locale) => locale.languageCode == systemLocale.languageCode,
      orElse: () => const Locale('en', 'US'),
    );

    return supportedLocale;
  }

  // Save locale to preferences
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    if (!_supportedLocales.contains(locale)) {
      throw Exception('Unsupported locale: $locale');
    }

    _currentLocale = locale;
    await _saveLocale(locale);
    notifyListeners();
  }

  // Set locale by language code
  Future<void> setLanguageCode(String languageCode) async {
    final locale = _supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'),
    );

    await setLocale(locale);
  }

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

// Extension for easy access to translations
extension TranslationExtension on BuildContext {
  String tr(String key) {
    final provider = LanguageProvider();
    return provider.translate(key);
  }

  String trWithParams(String key, Map<String, dynamic> params) {
    final provider = LanguageProvider();
    return provider.translateWithParams(key, params);
  }
}
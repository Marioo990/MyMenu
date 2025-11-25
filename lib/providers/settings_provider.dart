// import 'package:flutter/foundation.dart';
// import '../services/firebase_service.dart';
//
// class SettingsProvider with ChangeNotifier {
//   final FirebaseService _firebaseService;
//
//   // Restaurant Settings
//   Map<String, String> _restaurantName = {'en': 'Restaurant', 'pl': 'Restauracja'};
//   List<String> _activeLanguages = ['en', 'pl'];
//   String _defaultLanguage = 'en';
//   String _currency = 'USD';
//   bool _dayPeriodsEnabled = false;
//
//   // Menu Visibility Settings
//   bool _showImages = true;
//   bool _showThumbnails = true;
//
//   // Contact Information
//   String _address = '';
//   String _phone = '';
//   String _email = '';
//   double? _latitude;
//   double? _longitude;
//   Map<String, String> _openingHours = {};
//
//   // Loading state
//   bool _isLoading = false;
//   String? _error;
//
//   // Getters
//   String get restaurantName {
//     // Get name for current locale or default
//     final locale = _defaultLanguage;
//     return _restaurantName[locale] ?? _restaurantName['en'] ?? 'Restaurant';
//   }
//
//   Map<String, String> get restaurantNameMap => _restaurantName;
//   List<String> get activeLanguages => _activeLanguages;
//   String get defaultLanguage => _defaultLanguage;
//   String get currency => _currency;
//   bool get dayPeriodsEnabled => _dayPeriodsEnabled;
//   bool get showImages => _showImages;
//   bool get showThumbnails => _showThumbnails;
//   String get address => _address;
//   String get phone => _phone;
//   String get email => _email;
//   double? get latitude => _latitude;
//   double? get longitude => _longitude;
//   Map<String, String> get openingHours => _openingHours;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   SettingsProvider(this._firebaseService) {
//     _initializeSettings();
//   }
//
//   // Initialize settings from Firebase
//   Future<void> _initializeSettings() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       // Load general settings
//       final generalSettings = await _firebaseService.getSettings('general');
//       if (generalSettings.isNotEmpty) {
//         _restaurantName = Map<String, String>.from(generalSettings['restaurantName'] ?? {});
//         _activeLanguages = List<String>.from(generalSettings['activeLanguages'] ?? ['en']);
//         _defaultLanguage = generalSettings['defaultLanguage'] ?? 'en';
//         _currency = generalSettings['currency'] ?? 'USD';
//         _dayPeriodsEnabled = generalSettings['dayPeriodsEnabled'] ?? false;
//       }
//
//       // Load menu visibility settings
//       final menuVisibilitySettings = await _firebaseService.getSettings('menuVisibility');
//       if (menuVisibilitySettings.isNotEmpty) {
//         _showImages = menuVisibilitySettings['showImages'] ?? true;
//         _showThumbnails = menuVisibilitySettings['showThumbnails'] ?? true;
//       }
//
//       // Load contact settings
//       final contactSettings = await _firebaseService.getSettings('contact');
//       if (contactSettings.isNotEmpty) {
//         _address = contactSettings['address'] ?? '';
//         _phone = contactSettings['phone'] ?? '';
//         _email = contactSettings['email'] ?? '';
//         if (contactSettings['location'] != null) {
//           final location = contactSettings['location'];
//           _latitude = location['latitude'];
//           _longitude = location['longitude'];
//         }
//         _openingHours = Map<String, String>.from(contactSettings['openingHours'] ?? {});
//       }
//
//       // Set up real-time listeners
//       _setupRealtimeListeners();
//
//     } catch (e) {
//       _error = e.toString();
//       print('Error loading settings: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Set up real-time listeners for settings changes
//   void _setupRealtimeListeners() {
//     // General settings listener
//     _firebaseService.getSettingsStream('general').listen(
//           (settings) {
//         if (settings.isNotEmpty) {
//           _restaurantName = Map<String, String>.from(settings['restaurantName'] ?? {});
//           _activeLanguages = List<String>.from(settings['activeLanguages'] ?? ['en']);
//           _defaultLanguage = settings['defaultLanguage'] ?? 'en';
//           _currency = settings['currency'] ?? 'USD';
//           _dayPeriodsEnabled = settings['dayPeriodsEnabled'] ?? false;
//           notifyListeners();
//         }
//       },
//       onError: (error) {
//         _error = error.toString();
//         notifyListeners();
//       },
//     );
//
//     // Menu visibility settings listener
//     _firebaseService.getSettingsStream('menuVisibility').listen(
//           (settings) {
//         if (settings.isNotEmpty) {
//           _showImages = settings['showImages'] ?? true;
//           _showThumbnails = settings['showThumbnails'] ?? true;
//           notifyListeners();
//         }
//       },
//       onError: (error) {
//         _error = error.toString();
//         notifyListeners();
//       },
//     );
//
//     // Contact settings listener
//     _firebaseService.getSettingsStream('contact').listen(
//           (settings) {
//         if (settings.isNotEmpty) {
//           _address = settings['address'] ?? '';
//           _phone = settings['phone'] ?? '';
//           _email = settings['email'] ?? '';
//           if (settings['location'] != null) {
//             final location = settings['location'];
//             _latitude = location['latitude'];
//             _longitude = location['longitude'];
//           }
//           _openingHours = Map<String, String>.from(settings['openingHours'] ?? {});
//           notifyListeners();
//         }
//       },
//       onError: (error) {
//         _error = error.toString();
//         notifyListeners();
//       },
//     );
//   }
//
//   // Update restaurant name
//   Future<void> updateRestaurantName(Map<String, String> name) async {
//     try {
//       _restaurantName = name;
//       await _firebaseService.updateSettings('general', {
//         'restaurantName': name,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to update restaurant name: $e');
//     }
//   }
//
//   // Update active languages
//   Future<void> updateActiveLanguages(List<String> languages) async {
//     try {
//       _activeLanguages = languages;
//       await _firebaseService.updateSettings('general', {
//         'activeLanguages': languages,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to update active languages: $e');
//     }
//   }
//
//   // Update default language
//   Future<void> updateDefaultLanguage(String language) async {
//     try {
//       _defaultLanguage = language;
//       await _firebaseService.updateSettings('general', {
//         'defaultLanguage': language,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to update default language: $e');
//     }
//   }
//
//   // Update currency
//   Future<void> updateCurrency(String currency) async {
//     try {
//       _currency = currency;
//       await _firebaseService.updateSettings('general', {
//         'currency': currency,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to update currency: $e');
//     }
//   }
//
//   // Toggle day periods
//   Future<void> toggleDayPeriods(bool enabled) async {
//     try {
//       _dayPeriodsEnabled = enabled;
//       await _firebaseService.updateSettings('general', {
//         'dayPeriodsEnabled': enabled,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to toggle day periods: $e');
//     }
//   }
//
//   // Toggle show images
//   Future<void> toggleShowImages(bool show) async {
//     try {
//       _showImages = show;
//       await _firebaseService.updateSettings('menuVisibility', {
//         'showImages': show,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to toggle show images: $e');
//     }
//   }
//
//   // Toggle show thumbnails
//   Future<void> toggleShowThumbnails(bool show) async {
//     try {
//       _showThumbnails = show;
//       await _firebaseService.updateSettings('menuVisibility', {
//         'showThumbnails': show,
//       });
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to toggle show thumbnails: $e');
//     }
//   }
//
//   // Update contact information
//   Future<void> updateContactInfo({
//     String? address,
//     String? phone,
//     String? email,
//     double? latitude,
//     double? longitude,
//     Map<String, String>? openingHours,
//   }) async {
//     try {
//       final updates = <String, dynamic>{};
//
//       if (address != null) {
//         _address = address;
//         updates['address'] = address;
//       }
//
//       if (phone != null) {
//         _phone = phone;
//         updates['phone'] = phone;
//       }
//
//       if (email != null) {
//         _email = email;
//         updates['email'] = email;
//       }
//
//       if (latitude != null && longitude != null) {
//         _latitude = latitude;
//         _longitude = longitude;
//         updates['location'] = {
//           'latitude': latitude,
//           'longitude': longitude,
//         };
//       }
//
//       if (openingHours != null) {
//         _openingHours = openingHours;
//         updates['openingHours'] = openingHours;
//       }
//
//       if (updates.isNotEmpty) {
//         await _firebaseService.updateSettings('contact', updates);
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to update contact info: $e');
//     }
//   }
//
//   // Get restaurant name for specific locale
//   String getRestaurantNameForLocale(String locale) {
//     return _restaurantName[locale] ?? _restaurantName[_defaultLanguage] ?? 'Restaurant';
//   }
//
//   // Check if language is active
//   bool isLanguageActive(String languageCode) {
//     return _activeLanguages.contains(languageCode);
//   }
//
//   // Format opening hours for display
//   String formatOpeningHours(String locale) {
//     if (_openingHours.isEmpty) return '';
//
//     final days = locale == 'pl'
//         ? ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela']
//         : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//
//     final formatted = StringBuffer();
//     for (int i = 0; i < days.length; i++) {
//       final dayKey = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][i];
//       final hours = _openingHours[dayKey];
//       if (hours != null && hours.isNotEmpty) {
//         formatted.writeln('${days[i]}: $hours');
//       }
//     }
//
//     return formatted.toString().trim();
//   }
//
//   // Reset settings to defaults
//   Future<void> resetToDefaults() async {
//     try {
//       await Future.wait([
//         updateRestaurantName({'en': 'Restaurant', 'pl': 'Restauracja'}),
//         updateActiveLanguages(['en', 'pl']),
//         updateDefaultLanguage('en'),
//         updateCurrency('USD'),
//         toggleDayPeriods(false),
//         toggleShowImages(true),
//         toggleShowThumbnails(true),
//       ]);
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       throw Exception('Failed to reset settings: $e');
//     }
//   }
//
//   // Reload settings from Firebase
//   Future<void> reloadSettings() async {
//     await _initializeSettings();
//   }
// }
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class SettingsProvider with ChangeNotifier {
  import 'package:flutter/foundation.dart';
  import '../services/firebase_service.dart';

  class SettingsProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  String? _restaurantId;

  Map<String, String> _restaurantName = {'en': 'Restaurant'};
  List<String> _activeLanguages = ['en'];
  String _defaultLanguage = 'en';
  String _currency = 'USD';
  bool _dayPeriodsEnabled = false;
  bool _showImages = true;
  bool _showThumbnails = true;
  String _address = '';
  String _phone = '';
  String _email = '';
  Map<String, String> _openingHours = {};
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;
  String? _error;

  // Getters
  String get restaurantName => _restaurantName[_defaultLanguage] ?? 'Restaurant';
  Map<String, String> get restaurantNameMap => _restaurantName;
  List<String> get activeLanguages => _activeLanguages;
  String get defaultLanguage => _defaultLanguage;
  String get currency => _currency;
  bool get dayPeriodsEnabled => _dayPeriodsEnabled;
  bool get showImages => _showImages;
  bool get showThumbnails => _showThumbnails;
  String get address => _address;
  String get phone => _phone;
  String get email => _email;
  Map<String, String> get openingHours => _openingHours;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;

  SettingsProvider(this._firebaseService);

  // Init called after login
  Future<void> initData(String restaurantId) async {
  if (_restaurantId == restaurantId) return;
  _restaurantId = restaurantId;
  await _loadSettings();
  }

  Future<void> _loadSettings() async {
  if (_restaurantId == null) return;
  _isLoading = true;
  notifyListeners();

  try {
  final general = await _firebaseService.getSettings(_restaurantId!, 'general');
  if (general.isNotEmpty) {
  _restaurantName = Map<String, String>.from(general['restaurantName'] ?? {});
  _currency = general['currency'] ?? 'USD';
  _dayPeriodsEnabled = general['dayPeriodsEnabled'] ?? false;
  _defaultLanguage = general['defaultLanguage'] ?? 'en';
  if (general['activeLanguages'] != null) {
  _activeLanguages = List<String>.from(general['activeLanguages']);
  }
  }

  final visibility = await _firebaseService.getSettings(_restaurantId!, 'menuVisibility');
  if (visibility.isNotEmpty) {
  _showImages = visibility['showImages'] ?? true;
  _showThumbnails = visibility['showThumbnails'] ?? true;
  }

  final contact = await _firebaseService.getSettings(_restaurantId!, 'contact');
  if (contact.isNotEmpty) {
  _address = contact['address'] ?? '';
  _phone = contact['phone'] ?? '';
  _email = contact['email'] ?? '';
  _openingHours = Map<String, String>.from(contact['openingHours'] ?? {});
  if (contact['location'] != null) {
  _latitude = contact['location']['latitude'];
  _longitude = contact['location']['longitude'];
  }
  }
  } catch (e) {
  _error = e.toString();
  } finally {
  _isLoading = false;
  notifyListeners();
  }
  }

  // Update wrappers
  Future<void> updateRestaurantName(Map<String, String> name) async {
  if (_restaurantId == null) return;
  _restaurantName = name;
  await _firebaseService.updateSettings(_restaurantId!, 'general', {'restaurantName': name});
  notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
  if (_restaurantId == null) return;
  _currency = currency;
  await _firebaseService.updateSettings(_restaurantId!, 'general', {'currency': currency});
  notifyListeners();
  }

  Future<void> toggleDayPeriods(bool enabled) async {
  if (_restaurantId == null) return;
  _dayPeriodsEnabled = enabled;
  await _firebaseService.updateSettings(_restaurantId!, 'general', {'dayPeriodsEnabled': enabled});
  notifyListeners();
  }

  Future<void> toggleShowImages(bool show) async {
  if (_restaurantId == null) return;
  _showImages = show;
  await _firebaseService.updateSettings(_restaurantId!, 'menuVisibility', {'showImages': show});
  notifyListeners();
  }

  Future<void> toggleShowThumbnails(bool show) async {
  if (_restaurantId == null) return;
  _showThumbnails = show;
  await _firebaseService.updateSettings(_restaurantId!, 'menuVisibility', {'showThumbnails': show});
  notifyListeners();
  }

  Future<void> updateDefaultLanguage(String lang) async {
  if (_restaurantId == null) return;
  _defaultLanguage = lang;
  await _firebaseService.updateSettings(_restaurantId!, 'general', {'defaultLanguage': lang});
  notifyListeners();
  }

  Future<void> updateContactInfo({
  String? address, String? phone, String? email,
  Map<String, String>? openingHours,
  double? latitude, double? longitude
  }) async {
  if (_restaurantId == null) return;

  final data = <String, dynamic>{};
  if (address != null) { _address = address; data['address'] = address; }
  if (phone != null) { _phone = phone; data['phone'] = phone; }
  if (email != null) { _email = email; data['email'] = email; }
  if (openingHours != null) { _openingHours = openingHours; data['openingHours'] = openingHours; }
  if (latitude != null && longitude != null) {
  _latitude = latitude; _longitude = longitude;
  data['location'] = {'latitude': latitude, 'longitude': longitude};
  }

  await _firebaseService.updateSettings(_restaurantId!, 'contact', data);
  notifyListeners();
  }

  String getRestaurantNameForLocale(String locale) {
  return _restaurantName[locale] ?? _restaurantName[_defaultLanguage] ?? 'Restaurant';
  }
  }}
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
  final FirebaseService _firebaseService;

  // Restaurant Settings
  Map<String, String> _restaurantName = {'en': 'Restaurant', 'pl': 'Restauracja'};
  List<String> _activeLanguages = ['en', 'pl'];
  String _defaultLanguage = 'en';
  String _currency = 'USD';
  bool _dayPeriodsEnabled = false;

  // Menu Visibility Settings
  bool _showImages = true;
  bool _showThumbnails = true;

  // Contact Information
  String _address = '';
  String _phone = '';
  String _email = '';
  double? _latitude;
  double? _longitude;
  Map<String, String> _openingHours = {};

  // Loading state
  bool _isLoading = false;
  String? _error;

  // Getters
  String get restaurantName {
    // Get name for current locale or default
    final locale = _defaultLanguage;
    return _restaurantName[locale] ?? _restaurantName['en'] ?? 'Restaurant';
  }

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
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  Map<String, String> get openingHours => _openingHours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SettingsProvider(this._firebaseService) {
    _initializeSettings();
  }

  // Initialize settings from Firebase
  Future<void> _initializeSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔧 [SettingsProvider] Loading settings from Firestore...');

      // Load general settings with timeout
      final generalSettings = await _firebaseService
          .getSettings('general')
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ [SettingsProvider] General settings timeout - using defaults');
          return <String, dynamic>{};
        },
      );

      if (generalSettings.isNotEmpty) {
        print('✅ [SettingsProvider] General settings loaded: ${generalSettings.keys}');

        // Safely parse restaurant name
        if (generalSettings['restaurantName'] != null) {
          try {
            _restaurantName = Map<String, String>.from(generalSettings['restaurantName']);
            print('   Restaurant name: $_restaurantName');
          } catch (e) {
            print('⚠️ [SettingsProvider] Error parsing restaurantName: $e');
          }
        }

        // Safely parse active languages
        if (generalSettings['activeLanguages'] != null) {
          try {
            _activeLanguages = List<String>.from(generalSettings['activeLanguages']);
            print('   Active languages: $_activeLanguages');
          } catch (e) {
            print('⚠️ [SettingsProvider] Error parsing activeLanguages: $e');
          }
        }

        _defaultLanguage = generalSettings['defaultLanguage'] ?? 'en';
        _currency = generalSettings['currency'] ?? 'USD';
        _dayPeriodsEnabled = generalSettings['dayPeriodsEnabled'] ?? false;

        print('   Default language: $_defaultLanguage');
        print('   Currency: $_currency');
        print('   Day periods enabled: $_dayPeriodsEnabled');
      } else {
        print('⚠️ [SettingsProvider] No general settings found - using defaults');
        print('   Restaurant name: $_restaurantName');
        print('   Default language: $_defaultLanguage');
        print('   Currency: $_currency');
      }

      // Load menu visibility settings with timeout
      print('🔧 [SettingsProvider] Loading menu visibility settings...');
      final menuVisibilitySettings = await _firebaseService
          .getSettings('menuVisibility')
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ [SettingsProvider] Menu visibility timeout - using defaults');
          return <String, dynamic>{};
        },
      );

      if (menuVisibilitySettings.isNotEmpty) {
        _showImages = menuVisibilitySettings['showImages'] ?? true;
        _showThumbnails = menuVisibilitySettings['showThumbnails'] ?? true;
        print('✅ [SettingsProvider] Menu visibility loaded');
        print('   Show images: $_showImages');
        print('   Show thumbnails: $_showThumbnails');
      } else {
        print('⚠️ [SettingsProvider] No menu visibility settings found - using defaults');
      }

      // Load contact settings with timeout
      print('🔧 [SettingsProvider] Loading contact settings...');
      final contactSettings = await _firebaseService
          .getSettings('contact')
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ [SettingsProvider] Contact settings timeout - using defaults');
          return <String, dynamic>{};
        },
      );

      if (contactSettings.isNotEmpty) {
        _address = contactSettings['address'] ?? '';
        _phone = contactSettings['phone'] ?? '';
        _email = contactSettings['email'] ?? '';

        if (contactSettings['location'] != null) {
          try {
            final location = contactSettings['location'];
            _latitude = location['latitude'];
            _longitude = location['longitude'];
            print('   Location: $_latitude, $_longitude');
          } catch (e) {
            print('⚠️ [SettingsProvider] Error parsing location: $e');
          }
        }

        if (contactSettings['openingHours'] != null) {
          try {
            _openingHours = Map<String, String>.from(contactSettings['openingHours']);
          } catch (e) {
            print('⚠️ [SettingsProvider] Error parsing opening hours: $e');
          }
        }

        print('✅ [SettingsProvider] Contact settings loaded');
        print('   Address: $_address');
        print('   Phone: $_phone');
        print('   Email: $_email');
      } else {
        print('⚠️ [SettingsProvider] No contact settings found - using defaults');
      }

      print('✅ [SettingsProvider] Settings initialized successfully');

      // Set up real-time listeners (non-blocking)
      _setupRealtimeListeners();

    } catch (e, stackTrace) {
      _error = e.toString();
      print('❌ [SettingsProvider] Error loading settings: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 [SettingsProvider] Initialization complete (loading: $_isLoading, error: $_error)');
    }
  }

  // Set up real-time listeners for settings changes
  void _setupRealtimeListeners() {
    print('👂 [SettingsProvider] Setting up real-time listeners...');

    try {
      // General settings listener
      _firebaseService.getSettingsStream('general').listen(
            (settings) {
          if (settings.isNotEmpty) {
            print('🔄 [SettingsProvider] General settings updated from stream');

            if (settings['restaurantName'] != null) {
              try {
                _restaurantName = Map<String, String>.from(settings['restaurantName']);
              } catch (e) {
                print('⚠️ [SettingsProvider] Stream: Error parsing restaurantName: $e');
              }
            }

            if (settings['activeLanguages'] != null) {
              try {
                _activeLanguages = List<String>.from(settings['activeLanguages']);
              } catch (e) {
                print('⚠️ [SettingsProvider] Stream: Error parsing activeLanguages: $e');
              }
            }

            _defaultLanguage = settings['defaultLanguage'] ?? 'en';
            _currency = settings['currency'] ?? 'USD';
            _dayPeriodsEnabled = settings['dayPeriodsEnabled'] ?? false;
            notifyListeners();
          }
        },
        onError: (error) {
          print('⚠️ [SettingsProvider] General settings stream error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );

      // Menu visibility settings listener
      _firebaseService.getSettingsStream('menuVisibility').listen(
            (settings) {
          if (settings.isNotEmpty) {
            print('🔄 [SettingsProvider] Menu visibility updated from stream');
            _showImages = settings['showImages'] ?? true;
            _showThumbnails = settings['showThumbnails'] ?? true;
            notifyListeners();
          }
        },
        onError: (error) {
          print('⚠️ [SettingsProvider] Menu visibility stream error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );

      // Contact settings listener
      _firebaseService.getSettingsStream('contact').listen(
            (settings) {
          if (settings.isNotEmpty) {
            print('🔄 [SettingsProvider] Contact settings updated from stream');
            _address = settings['address'] ?? '';
            _phone = settings['phone'] ?? '';
            _email = settings['email'] ?? '';

            if (settings['location'] != null) {
              try {
                final location = settings['location'];
                _latitude = location['latitude'];
                _longitude = location['longitude'];
              } catch (e) {
                print('⚠️ [SettingsProvider] Stream: Error parsing location: $e');
              }
            }

            if (settings['openingHours'] != null) {
              try {
                _openingHours = Map<String, String>.from(settings['openingHours']);
              } catch (e) {
                print('⚠️ [SettingsProvider] Stream: Error parsing opening hours: $e');
              }
            }

            notifyListeners();
          }
        },
        onError: (error) {
          print('⚠️ [SettingsProvider] Contact settings stream error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );

      print('✅ [SettingsProvider] Real-time listeners set up successfully');
    } catch (e) {
      print('❌ [SettingsProvider] Error setting up listeners: $e');
    }
  }

  // Update restaurant name
  Future<void> updateRestaurantName(Map<String, String> name) async {
    try {
      print('💾 [SettingsProvider] Updating restaurant name: $name');
      _restaurantName = name;
      await _firebaseService.updateSettings('general', {
        'restaurantName': name,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Restaurant name updated');
    } catch (e) {
      print('❌ [SettingsProvider] Error updating restaurant name: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update restaurant name: $e');
    }
  }

  // Update active languages
  Future<void> updateActiveLanguages(List<String> languages) async {
    try {
      print('💾 [SettingsProvider] Updating active languages: $languages');
      _activeLanguages = languages;
      await _firebaseService.updateSettings('general', {
        'activeLanguages': languages,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Active languages updated');
    } catch (e) {
      print('❌ [SettingsProvider] Error updating active languages: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update active languages: $e');
    }
  }

  // Update default language
  Future<void> updateDefaultLanguage(String language) async {
    try {
      print('💾 [SettingsProvider] Updating default language: $language');
      _defaultLanguage = language;
      await _firebaseService.updateSettings('general', {
        'defaultLanguage': language,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Default language updated');
    } catch (e) {
      print('❌ [SettingsProvider] Error updating default language: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update default language: $e');
    }
  }

  // Update currency
  Future<void> updateCurrency(String currency) async {
    try {
      print('💾 [SettingsProvider] Updating currency: $currency');
      _currency = currency;
      await _firebaseService.updateSettings('general', {
        'currency': currency,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Currency updated');
    } catch (e) {
      print('❌ [SettingsProvider] Error updating currency: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update currency: $e');
    }
  }

  // Toggle day periods
  Future<void> toggleDayPeriods(bool enabled) async {
    try {
      print('💾 [SettingsProvider] Toggling day periods: $enabled');
      _dayPeriodsEnabled = enabled;
      await _firebaseService.updateSettings('general', {
        'dayPeriodsEnabled': enabled,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Day periods toggled');
    } catch (e) {
      print('❌ [SettingsProvider] Error toggling day periods: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to toggle day periods: $e');
    }
  }

  // Toggle show images
  Future<void> toggleShowImages(bool show) async {
    try {
      print('💾 [SettingsProvider] Toggling show images: $show');
      _showImages = show;
      await _firebaseService.updateSettings('menuVisibility', {
        'showImages': show,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Show images toggled');
    } catch (e) {
      print('❌ [SettingsProvider] Error toggling show images: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to toggle show images: $e');
    }
  }

  // Toggle show thumbnails
  Future<void> toggleShowThumbnails(bool show) async {
    try {
      print('💾 [SettingsProvider] Toggling show thumbnails: $show');
      _showThumbnails = show;
      await _firebaseService.updateSettings('menuVisibility', {
        'showThumbnails': show,
      });
      notifyListeners();
      print('✅ [SettingsProvider] Show thumbnails toggled');
    } catch (e) {
      print('❌ [SettingsProvider] Error toggling show thumbnails: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to toggle show thumbnails: $e');
    }
  }

  // Update contact information
  Future<void> updateContactInfo({
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    Map<String, String>? openingHours,
  }) async {
    try {
      print('💾 [SettingsProvider] Updating contact info...');
      final updates = <String, dynamic>{};

      if (address != null) {
        _address = address;
        updates['address'] = address;
      }

      if (phone != null) {
        _phone = phone;
        updates['phone'] = phone;
      }

      if (email != null) {
        _email = email;
        updates['email'] = email;
      }

      if (latitude != null && longitude != null) {
        _latitude = latitude;
        _longitude = longitude;
        updates['location'] = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      if (openingHours != null) {
        _openingHours = openingHours;
        updates['openingHours'] = openingHours;
      }

      if (updates.isNotEmpty) {
        await _firebaseService.updateSettings('contact', updates);
        notifyListeners();
        print('✅ [SettingsProvider] Contact info updated');
      }
    } catch (e) {
      print('❌ [SettingsProvider] Error updating contact info: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update contact info: $e');
    }
  }

  // Get restaurant name for specific locale
  String getRestaurantNameForLocale(String locale) {
    return _restaurantName[locale] ?? _restaurantName[_defaultLanguage] ?? 'Restaurant';
  }

  // Check if language is active
  bool isLanguageActive(String languageCode) {
    return _activeLanguages.contains(languageCode);
  }

  // Format opening hours for display
  String formatOpeningHours(String locale) {
    if (_openingHours.isEmpty) return '';

    final days = locale == 'pl'
        ? ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final formatted = StringBuffer();
    for (int i = 0; i < days.length; i++) {
      final dayKey = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][i];
      final hours = _openingHours[dayKey];
      if (hours != null && hours.isNotEmpty) {
        formatted.writeln('${days[i]}: $hours');
      }
    }

    return formatted.toString().trim();
  }

  // Reset settings to defaults
  Future<void> resetToDefaults() async {
    try {
      print('🔄 [SettingsProvider] Resetting to defaults...');
      await Future.wait([
        updateRestaurantName({'en': 'Restaurant', 'pl': 'Restauracja'}),
        updateActiveLanguages(['en', 'pl']),
        updateDefaultLanguage('en'),
        updateCurrency('USD'),
        toggleDayPeriods(false),
        toggleShowImages(true),
        toggleShowThumbnails(true),
      ]);
      print('✅ [SettingsProvider] Reset to defaults complete');
    } catch (e) {
      print('❌ [SettingsProvider] Error resetting settings: $e');
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to reset settings: $e');
    }
  }

  // Reload settings from Firebase
  Future<void> reloadSettings() async {
    print('🔄 [SettingsProvider] Reloading settings...');
    await _initializeSettings();
  }
}
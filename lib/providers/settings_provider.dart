import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class SettingsProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  String? _restaurantId;

  // Domyślne wartości
  Map<String, String> _restaurantName = {'en': 'Restaurant', 'pl': 'Restauracja'};
  List<String> _activeLanguages = ['en', 'pl'];
  String _defaultLanguage = 'en';
  String _currency = 'USD';
  bool _dayPeriodsEnabled = false;

  // Widoczność
  bool _showImages = true;
  bool _showThumbnails = true;

  // Kontakt
  String _address = '';
  String _phone = '';
  String _email = '';
  Map<String, String> _openingHours = {};
  double? _latitude;
  double? _longitude;

  // Stan
  bool _isLoading = false;
  String? _error;

  // Getters
  String get restaurantName {
    return _restaurantName[_defaultLanguage] ?? _restaurantName['en'] ?? 'Restaurant';
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
  Map<String, String> get openingHours => _openingHours;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get restaurantId => _restaurantId;

  SettingsProvider(this._firebaseService);

  // Inicjalizacja po zalogowaniu
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
        if (general['restaurantName'] != null) {
          _restaurantName = Map<String, String>.from(general['restaurantName']);
        }
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
      print('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Metody Aktualizacji ---

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
}
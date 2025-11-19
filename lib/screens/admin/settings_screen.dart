import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';

import '../../services/firebase_service.dart';
import 'dart:convert';
import 'dart:html' as html;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _restaurantNameEnController;
  late final TextEditingController _restaurantNamePlController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late String _currency;
  late bool _dayPeriodsEnabled;
  late bool _showImages;
  late bool _showThumbnails;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _restaurantNameEnController = TextEditingController(
      text: settings.restaurantNameMap['en'] ?? '',
    );
    _restaurantNamePlController = TextEditingController(
      text: settings.restaurantNameMap['pl'] ?? '',
    );
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _emailController = TextEditingController(text: settings.email);
    _currency = settings.currency;
    _dayPeriodsEnabled = settings.dayPeriodsEnabled;
    _showImages = settings.showImages;
    _showThumbnails = settings.showThumbnails;
  }

  @override
  void dispose() {
    _restaurantNameEnController.dispose();
    _restaurantNamePlController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ustawienia'), // PL
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ogólne', icon: Icon(Icons.settings)), // PL
              Tab(text: 'Kontakt', icon: Icon(Icons.contact_phone)), // PL
              Tab(text: 'Wygląd', icon: Icon(Icons.visibility)), // PL
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              // General Settings Tab
              _buildGeneralSettings(settingsProvider, languageProvider),

              // Contact Settings Tab
              _buildContactSettings(settingsProvider, languageProvider),

              // Display Settings Tab
              _buildDisplaySettings(settingsProvider, languageProvider),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveSettings,
          icon: const Icon(Icons.save),
          label: const Text('Zapisz ustawienia'), // PL
          backgroundColor: AppTheme.successColor,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(SettingsProvider settingsProvider, LanguageProvider languageProvider) {
    return SingleChildScrollView(
      padding: AppTheme.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Name Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant, color: AppTheme.primaryColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Nazwa Restauracji', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  TextFormField(
                    controller: _restaurantNameEnController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa (Angielski)', // PL
                      hintText: 'Nazwa Twojej Restauracji',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nazwa restauracji jest wymagana'; // PL
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextFormField(
                    controller: _restaurantNamePlController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa (Polski)', // PL
                      hintText: 'Nazwa Restauracji',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Currency & Localization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppTheme.secondaryColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Lokalizacja', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Currency Dropdown
                  DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Waluta', // PL
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    items: ['USD', 'EUR', 'GBP', 'PLN'].map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _currency = value!;
                      });
                    },
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Default Language
                  DropdownButtonFormField<String>(
                    value: settingsProvider.defaultLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Domyślny język', // PL
                      prefixIcon: Icon(Icons.translate),
                    ),
                    items: languageProvider.supportedLocales.map((locale) {
                      return DropdownMenuItem(
                        value: locale.languageCode,
                        child: Row(
                          children: [
                            Text(languageProvider.getLanguageFlag(locale.languageCode)),
                            const SizedBox(width: AppTheme.spacingM),
                            Text(languageProvider.getLanguageName(locale.languageCode)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      settingsProvider.updateDefaultLanguage(value!);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.featured_play_list, color: AppTheme.warningColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Funkcje', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  SwitchListTile(
                    title: const Text('Pory dnia'), // PL
                    subtitle: const Text('Włącz pory śniadaniowe, obiadowe, kolacyjne'), // PL
                    secondary: const Icon(Icons.schedule),
                    value: _dayPeriodsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _dayPeriodsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSettings(SettingsProvider settingsProvider, LanguageProvider languageProvider) {
    return SingleChildScrollView(
      padding: AppTheme.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.contact_phone, color: AppTheme.primaryColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Dane Kontaktowe', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adres', // PL
                      hintText: 'Ul. Przykładowa 1, Miasto',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefon', // PL
                      hintText: '+48 123 456 789',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email', // PL
                      hintText: 'kontakt@restauracja.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.contains('@')) {
                        return 'Nieprawidłowy adres email'; // PL
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Opening Hours
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppTheme.secondaryColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Godziny otwarcia', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  _buildOpeningHoursEditor(settingsProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(SettingsProvider settingsProvider, LanguageProvider languageProvider) {
    return SingleChildScrollView(
      padding: AppTheme.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Display Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image, color: AppTheme.primaryColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Ustawienia Obrazów', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  SwitchListTile(
                    title: const Text('Pokaż Obrazy'), // PL
                    subtitle: const Text('Wyświetlaj zdjęcia dań w widoku szczegółów'), // PL
                    secondary: const Icon(Icons.photo),
                    value: _showImages,
                    onChanged: (value) {
                      setState(() {
                        _showImages = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Pokaż Miniatury'), // PL
                    subtitle: const Text('Wyświetlaj miniatury na liście menu'), // PL
                    secondary: const Icon(Icons.photo_size_select_actual),
                    value: _showThumbnails,
                    onChanged: (value) {
                      setState(() {
                        _showThumbnails = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Export/Import
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.import_export, color: AppTheme.warningColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Zarządzanie Danymi', // PL
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportData,
                          icon: const Icon(Icons.download),
                          label: const Text('Eksportuj Dane'), // PL
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importData,
                          icon: const Icon(Icons.upload),
                          label: const Text('Importuj Dane'), // PL
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursEditor(SettingsProvider settingsProvider) {
    final days = [
      {'key': 'mon', 'label': 'Poniedziałek'}, // PL
      {'key': 'tue', 'label': 'Wtorek'}, // PL
      {'key': 'wed', 'label': 'Środa'}, // PL
      {'key': 'thu', 'label': 'Czwartek'}, // PL
      {'key': 'fri', 'label': 'Piątek'}, // PL
      {'key': 'sat', 'label': 'Sobota'}, // PL
      {'key': 'sun', 'label': 'Niedziela'}, // PL
    ];

    final controllers = <String, TextEditingController>{};
    for (final day in days) {
      controllers[day['key']!] = TextEditingController(
        text: settingsProvider.openingHours[day['key']!] ?? '9:00 - 22:00',
      );
    }

    return Column(
      children: days.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: TextFormField(
            controller: controllers[day['key']!],
            decoration: InputDecoration(
              labelText: day['label'],
              hintText: '9:00 - 22:00 lub Zamknięte', // PL
              prefixIcon: const Icon(Icons.access_time),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    try {
      // Save restaurant name
      await settingsProvider.updateRestaurantName({
        'en': _restaurantNameEnController.text,
        'pl': _restaurantNamePlController.text,
      });

      // Save currency
      await settingsProvider.updateCurrency(_currency);

      // Save features
      await settingsProvider.toggleDayPeriods(_dayPeriodsEnabled);
      await settingsProvider.toggleShowImages(_showImages);
      await settingsProvider.toggleShowThumbnails(_showThumbnails);

      // Save contact info
      await settingsProvider.updateContactInfo(
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ustawienia zapisane pomyślnie'), // PL
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd zapisu ustawień: $e'), // PL
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _exportData() async {
    try {
      // Pobierz FirebaseService przez Provider
      final firebaseService = context.read<FirebaseService>();
      final data = await firebaseService.exportData();
      final jsonStr = jsonEncode(data);

      // Dla Web - pobierz plik
      final bytes = utf8.encode(jsonStr);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = 'menu_export_${DateTime.now().millisecondsSinceEpoch}.json';
      anchor.click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dane wyeksportowane pomyślnie'), // PL
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eksport nieudany: $e'), // PL
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _importData() async {
    try {
      // Utwórz input element
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'application/json,.json';
      uploadInput.click();

      await uploadInput.onChange.first;
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsText(file);
      await reader.onLoadEnd.first;

      final jsonStr = reader.result as String;
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final firebaseService = context.read<FirebaseService>();
      await firebaseService.importData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dane zaimportowane pomyślnie'), // PL
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import nieudany: $e'), // PL
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
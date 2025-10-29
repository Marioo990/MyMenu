import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';

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
          title: Text(languageProvider.translate('settings')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General', icon: Icon(Icons.settings)),
              Tab(text: 'Contact', icon: Icon(Icons.contact_phone)),
              Tab(text: 'Display', icon: Icon(Icons.visibility)),
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
          label: Text(languageProvider.translate('save_settings')),
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
                        'Restaurant Name',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  TextFormField(
                    controller: _restaurantNameEnController,
                    decoration: const InputDecoration(
                      labelText: 'Name (English)',
                      hintText: 'Your Restaurant Name',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Restaurant name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextFormField(
                    controller: _restaurantNamePlController,
                    decoration: const InputDecoration(
                      labelText: 'Name (Polish)',
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
                        'Localization',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Currency Dropdown
                  DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
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
                      labelText: 'Default Language',
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
                        'Features',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  SwitchListTile(
                    title: const Text('Day Periods'),
                    subtitle: const Text('Enable breakfast, lunch, dinner periods'),
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
                        'Contact Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: '123 Main Street, City, Country',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: '+1 234 567 8900',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'contact@restaurant.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.contains('@')) {
                        return 'Invalid email address';
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
                        'Opening Hours',
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
                        'Image Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  SwitchListTile(
                    title: const Text('Show Images'),
                    subtitle: const Text('Display item images in detail view'),
                    secondary: const Icon(Icons.photo),
                    value: _showImages,
                    onChanged: (value) {
                      setState(() {
                        _showImages = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Show Thumbnails'),
                    subtitle: const Text('Display thumbnails in menu list'),
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
                        'Data Management',
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
                          label: const Text('Export Data'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importData,
                          icon: const Icon(Icons.upload),
                          label: const Text('Import Data'),
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
      {'key': 'mon', 'label': 'Monday'},
      {'key': 'tue', 'label': 'Tuesday'},
      {'key': 'wed', 'label': 'Wednesday'},
      {'key': 'thu', 'label': 'Thursday'},
      {'key': 'fri', 'label': 'Friday'},
      {'key': 'sat', 'label': 'Saturday'},
      {'key': 'sun', 'label': 'Sunday'},
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
              hintText: '9:00 - 22:00 or Closed',
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
            content: Text('Settings saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _exportData() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality to be implemented')),
    );
  }

  void _importData() {
    // Implement import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality to be implemented')),
    );
  }
}
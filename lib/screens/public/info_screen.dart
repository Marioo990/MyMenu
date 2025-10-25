import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('restaurant_info')),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Header
            _buildRestaurantHeader(context, settingsProvider),

            const SizedBox(height: AppTheme.spacingXL),

            // Contact Section
            _buildContactSection(context, settingsProvider, languageProvider),

            const SizedBox(height: AppTheme.spacingXL),

            // Map Section
            if (settingsProvider.latitude != null && settingsProvider.longitude != null)
              _buildMapSection(context, settingsProvider, languageProvider),

            const SizedBox(height: AppTheme.spacingXL),

            // Opening Hours
            _buildOpeningHoursSection(context, settingsProvider, languageProvider, locale),

            const SizedBox(height: AppTheme.spacingXL),

            // Social Media (optional)
            _buildSocialMediaSection(context, languageProvider),

            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: AppTheme.elevationM,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🍽️',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              settingsProvider.restaurantName,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Fine Dining Experience',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context,
      SettingsProvider settingsProvider,
      LanguageProvider languageProvider,
      ) {
    return Card(
      elevation: AppTheme.elevationS,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('contact'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Address
            if (settingsProvider.address.isNotEmpty)
              _buildContactItem(
                context,
                Icons.location_on,
                languageProvider.translate('address'),
                settingsProvider.address,
                    () => _openMaps(settingsProvider),
              ),

            // Phone
            if (settingsProvider.phone.isNotEmpty)
              _buildContactItem(
                context,
                Icons.phone,
                languageProvider.translate('phone'),
                settingsProvider.phone,
                    () => _makePhoneCall(settingsProvider.phone),
              ),

            // Email
            if (settingsProvider.email.isNotEmpty)
              _buildContactItem(
                context,
                Icons.email,
                languageProvider.translate('email'),
                settingsProvider.email,
                    () => _sendEmail(settingsProvider.email),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingM,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(
      BuildContext context,
      SettingsProvider settingsProvider,
      LanguageProvider languageProvider,
      ) {
    return Card(
      elevation: AppTheme.elevationS,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Text(
              languageProvider.translate('location'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          // Map placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusL),
                bottomRight: Radius.circular(AppTheme.radiusL),
              ),
            ),
            child: Stack(
              children: [
                // Google Maps would go here
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Map View',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: AppTheme.spacingM,
                  bottom: AppTheme.spacingM,
                  child: FloatingActionButton.small(
                    onPressed: () => _openMaps(settingsProvider),
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.directions),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursSection(
      BuildContext context,
      SettingsProvider settingsProvider,
      LanguageProvider languageProvider,
      String locale,
      ) {
    final days = locale == 'pl'
        ? ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return Card(
      elevation: AppTheme.elevationS,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('opening_hours'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ...List.generate(days.length, (index) {
              final hours = settingsProvider.openingHours[dayKeys[index]] ??
                  languageProvider.translate('closed');
              final isToday = DateTime.now().weekday == index + 1;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isToday ? AppTheme.primaryColor.withOpacity(0.05) : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isToday)
                          Container(
                            width: 4,
                            height: 20,
                            margin: const EdgeInsets.only(right: AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        Text(
                          days[index],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hours,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hours == languageProvider.translate('closed')
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(BuildContext context, LanguageProvider languageProvider) {
    return Card(
      elevation: AppTheme.elevationS,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('follow_us'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  'Facebook',
                  Icons.facebook,
                  Colors.blue,
                      () => _openUrl('https://facebook.com'),
                ),
                _buildSocialButton(
                  'Instagram',
                  Icons.camera_alt,
                  Colors.pink,
                      () => _openUrl('https://instagram.com'),
                ),
                _buildSocialButton(
                  'Twitter',
                  Icons.alternate_email,
                  Colors.lightBlue,
                      () => _openUrl('https://twitter.com'),
                ),
                _buildSocialButton(
                  'TikTok',
                  Icons.music_note,
                  Colors.black,
                      () => _openUrl('https://tiktok.com'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String name,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      tooltip: name,
    );
  }

  Future<void> _openMaps(SettingsProvider settingsProvider) async {
    if (settingsProvider.latitude == null || settingsProvider.longitude == null) {
      // Use address
      final uri = Uri.parse(
          'https://maps.google.com/?q=${Uri.encodeComponent(settingsProvider.address)}'
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      // Use coordinates
      final uri = Uri.parse(
          'https://maps.google.com/?q=${settingsProvider.latitude},${settingsProvider.longitude}'
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
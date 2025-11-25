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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          languageProvider.translate('restaurant_info'),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name & Logo
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    settingsProvider.getRestaurantNameForLocale(locale),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),
            const Divider(),
            const SizedBox(height: AppTheme.spacingXL),

            // Contact Section
            _buildSectionTitle(
              context,
              languageProvider.translate('contact'),
              Icons.contact_phone,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Address
            if (settingsProvider.address.isNotEmpty)
              _buildContactTile(
                context,
                icon: Icons.location_on,
                title: languageProvider.translate('address'),
                subtitle: settingsProvider.address,
                onTap: () => _openMaps(settingsProvider),
              ),

            // Phone
            if (settingsProvider.phone.isNotEmpty)
              _buildContactTile(
                context,
                icon: Icons.phone,
                title: languageProvider.translate('phone'),
                subtitle: settingsProvider.phone,
                onTap: () => _makePhoneCall(settingsProvider.phone),
              ),

            // Email
            if (settingsProvider.email.isNotEmpty)
              _buildContactTile(
                context,
                icon: Icons.email,
                title: languageProvider.translate('email'),
                subtitle: settingsProvider.email,
                onTap: () => _sendEmail(settingsProvider.email),
              ),

            const SizedBox(height: AppTheme.spacingXL),

            // Opening Hours
            if (settingsProvider.openingHours.isNotEmpty) ...[
              _buildSectionTitle(
                context,
                languageProvider.translate('opening_hours'),
                Icons.schedule,
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildOpeningHours(context, settingsProvider, languageProvider),
              const SizedBox(height: AppTheme.spacingXL),
            ],

            // Map
            if (settingsProvider.latitude != null && settingsProvider.longitude != null) ...[
              _buildSectionTitle(
                context,
                languageProvider.translate('location'),
                Icons.map,
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildMap(context, settingsProvider),
              const SizedBox(height: AppTheme.spacingXL),
            ],

            // Social Media
            _buildSectionTitle(
              context,
              languageProvider.translate('follow_us'),
              Icons.share,
            ),
            const SizedBox(height: AppTheme.spacingL),
            _buildSocialMedia(context),

            const SizedBox(height: AppTheme.spacingXL),

            // Additional Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Text(
                          languageProvider.translate('about_us'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      _getAboutUsText(locale),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: AppTheme.spacingM),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOpeningHours(
      BuildContext context,
      SettingsProvider settingsProvider,
      LanguageProvider languageProvider,
      ) {
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayNames = [
      languageProvider.translate('monday'),
      languageProvider.translate('tuesday'),
      languageProvider.translate('wednesday'),
      languageProvider.translate('thursday'),
      languageProvider.translate('friday'),
      languageProvider.translate('saturday'),
      languageProvider.translate('sunday'),
    ];

    // Get current day
    final currentDay = DateTime.now().weekday - 1; // 0-6

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final hours = settingsProvider.openingHours[day] ?? languageProvider.translate('closed');
            final isToday = index == currentDay;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              decoration: BoxDecoration(
                color: isToday ? AppTheme.secondaryColor.withOpacity(0.1) : null,
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
                          height: 24,
                          margin: const EdgeInsets.only(right: AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      Text(
                        dayNames[index],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    hours,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: hours == languageProvider.translate('closed')
                          ? AppTheme.textLight
                          : AppTheme.textPrimary,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () => _openMaps(settingsProvider),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
          ),
          child: Stack(
            children: [
              // Placeholder map image
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Tap to open in maps',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Overlay button
              Positioned(
                bottom: AppTheme.spacingM,
                right: AppTheme.spacingM,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Get Directions',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    final socialLinks = [
      {'icon': Icons.facebook, 'color': const Color(0xFF1877F2), 'url': 'https://facebook.com'},
      {'icon': Icons.camera_alt, 'color': const Color(0xFFE4405F), 'url': 'https://instagram.com'},
      {'icon': Icons.alternate_email, 'color': const Color(0xFF1DA1F2), 'url': 'https://twitter.com'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialLinks.map((link) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
          child: IconButton(
            onPressed: () => _launchURL(link['url'] as String),
            icon: Icon(
              link['icon'] as IconData,
              color: link['color'] as Color,
              size: 32,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getAboutUsText(String locale) {
    switch (locale) {
      case 'pl':
        return 'Witamy w naszej restauracji! Od ponad 20 lat serwujemy najlepsze dania kuchni międzynarodowej. '
            'Nasze menu łączy tradycję z nowoczesnością, oferując wyjątkowe doświadczenia kulinarne. '
            'Zapraszamy do odwiedzenia nas i spróbowania naszych specjalności!';
      case 'en':
      default:
        return 'Welcome to our restaurant! For over 20 years, we have been serving the best international cuisine. '
            'Our menu combines tradition with modernity, offering exceptional culinary experiences. '
            'We invite you to visit us and try our specialties!';
    }
  }

  Future<void> _openMaps(SettingsProvider settingsProvider) async {
    if (settingsProvider.latitude == null || settingsProvider.longitude == null) return;

    final url = 'https://maps.google.com/?q=${settingsProvider.latitude},${settingsProvider.longitude}';
    await _launchURL(url);
  }

  Future<void> _makePhoneCall(String phone) async {
    final url = 'tel:$phone';
    await _launchURL(url);
  }

  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email';
    await _launchURL(url);
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
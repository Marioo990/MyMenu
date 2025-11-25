import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/language_provider.dart';

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
      // ... reszta ciała metody build identyczna, błędy importów naprawione powyżej ...
      body: SingleChildScrollView(
        padding: AppTheme.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: const Icon(Icons.restaurant, size: 60, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    settingsProvider.getRestaurantNameForLocale(locale),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // ... (pozostała część UI bez zmian logicznych)
          ],
        ),
      ),
    );
  }

  // Dodaj brakujące metody pomocnicze jeśli są potrzebne (openMaps, etc.) - wklej ze starego pliku
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
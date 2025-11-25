import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';

// Providers
import 'providers/menu_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'providers/restaurant_provider.dart'; // Dodany RestaurantProvider

// Services
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/google_auth_service.dart';

// Screens - UWAGA: Zaktualizowane ścieżki do wersji Preview
import 'screens/admin/preview/menu_preview_screen.dart';
import 'screens/admin/preview/item_detail_preview_screen.dart';
import 'screens/admin/preview/info_preview_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  try {
    // Initialize Firebase
    print('📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Initialize services
    final firebaseService = FirebaseService();
    final authService = AuthService();

    // Enable offline persistence (opcjonalne, z obsługą błędu w web)
    print('💾 Enabling offline persistence...');
    try {
      await firebaseService.enableOfflinePersistence();
      print('✅ Offline persistence enabled');
    } catch (e) {
      print('⚠️ Offline persistence warning (safe to ignore on web): $e');
    }

    print('🎨 Creating app...');
    runApp(
      MultiProvider(
        providers: [
          Provider<FirebaseService>.value(value: firebaseService),
          Provider<AuthService>.value(value: authService),

          // Providers logiczne
          ChangeNotifierProvider(
            create: (_) {
              print('📦 Creating LanguageProvider...');
              return LanguageProvider();
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              print('❤️ Creating FavoritesProvider...');
              return FavoritesProvider();
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              print('🏢 Creating RestaurantProvider...'); // Nowy provider SaaS
              return RestaurantProvider();
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              print('⚙️ Creating SettingsProvider...');
              return SettingsProvider(firebaseService);
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              print('🍽️ Creating MenuProvider...');
              return MenuProvider(firebaseService);
            },
          ),
        ],
        child: const RestaurantMenuApp(),
      ),
    );
    print('✅ App created successfully');
  } catch (e, stackTrace) {
    print('❌ FATAL ERROR during initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');

    // Show error screen
    runApp(const ErrorApp());
  }
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building RestaurantMenuApp');

    return Consumer2<LanguageProvider, SettingsProvider>(
      builder: (context, languageProvider, settingsProvider, _) {
        final languageReady = !languageProvider.isLoading;
        // W SaaS ustawienia nie są gotowe na starcie (czekają na wybór restauracji),
        // więc usunęliśmy warunek settingsReady, aby nie blokować startu aplikacji.

        if (!languageReady) {
          print('⏳ Waiting for language to initialize...');
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Pobieranie nazwy restauracji (może być domyślna, dopóki admin nie wybierze kontekstu)
        String appTitle = 'Restaurant Menu';
        try {
          final name = settingsProvider.restaurantName;
          if (name.isNotEmpty) {
            appTitle = name;
          }
        } catch (e) {
          print('⚠️ Error getting restaurant name: $e');
        }

        return MaterialApp(
          title: appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          locale: languageProvider.currentLocale,
          supportedLocales: languageProvider.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (supportedLocales.isEmpty) return const Locale('en', 'US');

            if (locale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          // Używamy generatora tras z AppRoutes
          onGenerateRoute: AppRoutes.generateRoute,
          // Domyślna trasa (może przekierować np. do Admin Login jeśli user nie jest zalogowany)
          initialRoute: AppRoutes.menu,
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Initialization Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to initialize the application.\nPlease check your internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Restart app logic
                        main();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
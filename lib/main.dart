import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/menu_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';

// Flaga zapobiegająca podwójnej inicjalizacji
bool _isInitialized = false;

void main() async {
  // Zapobieganie podwójnej inicjalizacji
  if (_isInitialized) {
    print('⚠️ App already initialized, skipping...');
    return;
  }
  _isInitialized = true;

  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  try {
    // Initialize Firebase with timeout
    print('📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('❌ Firebase initialization timeout!');
        throw Exception('Firebase initialization timeout');
      },
    );
    print('✅ Firebase initialized successfully');

    // Initialize services
    final firebaseService = FirebaseService();
    final authService = AuthService();

    // Enable offline persistence with error handling
    print('💾 Enabling offline persistence...');
    try {
      await firebaseService.enableOfflinePersistence().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Offline persistence timeout - continuing anyway');
        },
      );
      print('✅ Offline persistence enabled');
    } catch (e) {
      print('⚠️ Offline persistence failed: $e - continuing anyway');
    }

    print('🎨 Creating app...');
    runApp(
      MultiProvider(
        providers: [
          Provider<FirebaseService>.value(value: firebaseService),
          Provider<AuthService>.value(value: authService),
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
    runApp(
      MaterialApp(
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 24),
                      const Text(
                        'Initialization Error',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _isInitialized = false; // Reset flagi
                          main(); // Restart app
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
      ),
    );
  }
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building RestaurantMenuApp');

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        // KRYTYCZNE: Sprawdź czy languageProvider jest zainicjalizowany
        if (languageProvider.currentLocale == null) {
          print('⚠️ LanguageProvider not initialized yet, waiting...');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US')],
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        print('   Language: ${languageProvider.currentLanguageCode}');

        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            // Check if still loading
            if (settingsProvider.isLoading) {
              print('⏳ Settings still loading...');
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: languageProvider.supportedLocales,
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Loading settings...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (settingsProvider.error != null) {
              print('❌ Settings error: ${settingsProvider.error}');
            }

            print('✅ Building main app with settings loaded');

            // KRYTYCZNE: Bezpieczne pobieranie danych z zabezpieczeniami
            String appTitle = 'Restaurant Menu'; // Domyślna wartość
            try {
              final name = settingsProvider.restaurantName;
              if (name.isNotEmpty) {
                appTitle = name;
              }
            } catch (e) {
              print('⚠️ Error getting restaurant name: $e');
            }

            // Sprawdź supportedLocales
            final locales = languageProvider.supportedLocales;
            if (locales.isEmpty) {
              print('⚠️ No supported locales, using default');
            }

            print('📱 Building MaterialApp with:');
            print('   - Title: $appTitle');
            print('   - Locale: ${languageProvider.currentLocale}');
            print('   - Supported locales: ${locales.length}');

            return MaterialApp(
              title: appTitle,
              debugShowCheckedModeBanner: false,

              // Theme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,

              // Localization - KRYTYCZNE: Wszystkie wartości muszą być non-null
              locale: languageProvider.currentLocale ?? const Locale('en', 'US'),
              supportedLocales: locales.isNotEmpty
                  ? locales
                  : const [Locale('en', 'US')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Navigation
              initialRoute: AppRoutes.menu,
              onGenerateRoute: AppRoutes.generateRoute,

              // Error handling
              builder: (context, widget) {
                // Catch any widget build errors
                ErrorWidget.builder = (FlutterErrorDetails details) {
                  print('🔴 Widget Error: ${details.exception}');
                  return Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Widget Error',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.exception.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                };
                return widget ?? const SizedBox();
              },
            );
          },
        );
      },
    );
  }
}
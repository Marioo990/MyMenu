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

void main() async {
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
                          // Reload the page
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
      ),
    );
  }
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building RestaurantMenuApp');

    return Consumer2<LanguageProvider, SettingsProvider>(
      builder: (context, languageProvider, settingsProvider, _) {
        // CRITICAL: Wait for both providers to initialize
        final languageReady = !languageProvider.isLoading;
        final settingsReady = !settingsProvider.isLoading;

        print('📊 Provider status:');
        print('   - Language ready: $languageReady (locale: ${languageProvider.currentLocale})');
        print('   - Settings ready: $settingsReady');

        // Show loading screen while initializing
        if (!languageReady || !settingsReady) {
          print('⏳ Waiting for providers to initialize...');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      !languageReady ? 'Loading language...' : 'Loading settings...',
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

        // Both providers are ready, build the app
        print('✅ All providers ready, building main app');

        // Safely get values with fallbacks
        final currentLocale = languageProvider.currentLocale;
        final supportedLocales = languageProvider.supportedLocales.toList();

        // Validate
        if (supportedLocales.isEmpty) {
          print('❌ No supported locales!');
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Configuration Error')),
            ),
          );
        }

        // Get app title with fallback
        String appTitle = 'Restaurant Menu';
        try {
          final name = settingsProvider.restaurantName;
          if (name.isNotEmpty) {
            appTitle = name;
          }
        } catch (e) {
          print('⚠️ Error getting restaurant name: $e');
        }

        print('📱 Building MaterialApp: Title=$appTitle, Locale=$currentLocale');

        return MaterialApp(
          title: appTitle,
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Localization
          locale: currentLocale,
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Locale resolution with error handling
          localeResolutionCallback: (locale, supportedLocales) {
            try {
              print('🌍 Resolving locale: $locale');

              if (locale == null || supportedLocales.isEmpty) {
                print('⚠️ Invalid locale data');
                return const Locale('en');
              }

              // Match by language code
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  print('✅ Using locale: $supportedLocale');
                  return supportedLocale;
                }
              }

              print('⚠️ Locale not supported, using: ${supportedLocales.first}');
              return supportedLocales.first;
            } catch (e) {
              print('❌ Error in localeResolutionCallback: $e');
              return const Locale('en');
            }
          },

          // Navigation with error handling
          initialRoute: AppRoutes.menu,
          onGenerateRoute: (settings) {
            try {
              print('🧭 Generating route: ${settings.name}');
              return AppRoutes.generateRoute(settings);
            } catch (e, stackTrace) {
              print('❌ Error generating route: $e');
              print('Stack trace: $stackTrace');
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(child: Text('Navigation Error: $e')),
                ),
              );
            }
          },

          // Unknown route handler
          onUnknownRoute: (settings) {
            print('❓ Unknown route: ${settings.name}');
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('404')),
                body: const Center(child: Text('Page not found')),
              ),
            );
          },

          // Error builder
          builder: (context, widget) {
            // Add error boundary
            ErrorWidget.builder = (FlutterErrorDetails details) {
              print('❌ Widget error: ${details.exception}');
              return Scaffold(
                body: Center(
                  child: Text('Error: ${details.exception}'),
                ),
              );
            };
            return widget ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
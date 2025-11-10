import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'providers/menu_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'config/routes.dart';
import 'services/database_initializer.dart';

// import 'config/routes.dart';
// import 'screens/public/menu_screen.dart';
// import 'screens/public/info_screen.dart';
// import 'screens/admin/admin_login_screen.dart';
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
// Initialize database with sample data if needed
    try {
      final initializer = DatabaseInitializer();
      final isInitialized = await initializer.isDatabaseInitialized();
      if (!isInitialized) {
        print('🔧 Initializing database with default data...');
        await initializer.initializeDatabase();
        print('✅ Database initialized with sample data');
      } else {
        print('✅ Database already has data');
      }
    } catch (e) {
      print('⚠️ Database initialization error: $e - continuing anyway');
    }
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
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 24),
                      const Text(
                        'Initialization Error',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
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
        final languageReady = !languageProvider.isLoading;
        final settingsReady = !settingsProvider.isLoading;

        print('📊 Provider status:');
        print(
            '   - Language ready: $languageReady (locale: ${languageProvider.currentLocale})');
        print('   - Settings ready: $settingsReady');

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
                      !languageReady
                          ? 'Loading language...'
                          : 'Loading settings...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        print('✅ All providers ready, building main app');

        // Get values ONCE and don't rebuild on stream changes
        final currentLocale = languageProvider.currentLocale;
        final supportedLocales = languageProvider.supportedLocales.toList();

        String appTitle = 'Restaurant Menu';
        try {
          final name = settingsProvider.restaurantName;
          if (name.isNotEmpty) {
            appTitle = name;
          }
        } catch (e) {
          print('⚠️ Error getting restaurant name: $e');
        }

        print(
            '📱 Building MaterialApp: Title=$appTitle, Locale=$currentLocale');

        // CRITICAL: Return MaterialApp WITHOUT rebuilding on stream changes
        return _RestaurantMenuAppCore(
          appTitle: appTitle,
          currentLocale: currentLocale,
          supportedLocales: supportedLocales,
        );
      },
    );
  }
}

// Separate widget to prevent rebuilds from Provider streams
class _RestaurantMenuAppCore extends StatelessWidget {
  final String appTitle;
  final Locale currentLocale;
  final List<Locale> supportedLocales;

  const _RestaurantMenuAppCore({
    required this.appTitle,
    required this.currentLocale,
    required this.supportedLocales,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: currentLocale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      // onGenerateRoute: (settings) {
      //   print('🧭 Route: ${settings.name}');
      //
      //   switch (settings.name) {
      //     case '/':
      //       return MaterialPageRoute(
      //         builder: (_) => const MenuScreen(), // Zmienione z SimpleMenuScreen
      //         settings: settings,
      //       );
      //
      //     case '/info':
      //       return MaterialPageRoute(
      //         builder: (_) => const InfoScreen(),
      //         settings: settings,
      //       );
      //
      //     case '/admin':
      //       return MaterialPageRoute(
      //         builder: (_) => const AdminLoginScreen(),
      //         settings: settings,
      //       );
      //
      //     default:
      //       return MaterialPageRoute(
      //         builder: (_) => Scaffold(
      //           appBar: AppBar(title: const Text('404')),
      //           body: const Center(child: Text('Page not found')),
      //         ),
      //         settings: settings,
      //       );
      //   }
      // },
    );
  }
}

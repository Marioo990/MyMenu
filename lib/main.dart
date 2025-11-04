// export 'main_debug.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'firebase_options.dart';
// import 'config/theme.dart';
// import 'config/routes.dart';
// import 'providers/menu_provider.dart';
// import 'providers/settings_provider.dart';
// import 'providers/favorites_provider.dart';
// import 'providers/language_provider.dart';
// import 'services/firebase_service.dart';
// import 'services/auth_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Initialize services
//   final firebaseService = FirebaseService();
//   final authService = AuthService();
//
//   // Enable offline persistence for Firestore
//   await firebaseService.enableOfflinePersistence();
//
//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<FirebaseService>.value(value: firebaseService),
//         Provider<AuthService>.value(value: authService),
//         ChangeNotifierProvider(create: (_) => SettingsProvider(firebaseService)),
//         ChangeNotifierProvider(create: (_) => LanguageProvider()),
//         ChangeNotifierProvider(create: (_) => MenuProvider(firebaseService)),
//         ChangeNotifierProvider(create: (_) => FavoritesProvider()),
//       ],
//       child: const RestaurantMenuApp(),
//     ),
//   );
// }
//
// class RestaurantMenuApp extends StatelessWidget {
//   const RestaurantMenuApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LanguageProvider>(
//       builder: (context, languageProvider, _) {
//         return Consumer<SettingsProvider>(
//           builder: (context, settingsProvider, _) {
//             return MaterialApp(
//               title: settingsProvider.restaurantName,
//               debugShowCheckedModeBanner: false,
//               theme: AppTheme.lightTheme,
//               darkTheme: AppTheme.darkTheme,
//               themeMode: ThemeMode.light,
//               locale: languageProvider.currentLocale,
//               supportedLocales: languageProvider.supportedLocales,
//               initialRoute: AppRoutes.menu,
//               onGenerateRoute: AppRoutes.generateRoute,
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
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
                          // W Flutter Web możemy użyć window tylko dla web
                          // Dla innych platform użyjemy Phoenix pattern
                          WidgetsFlutterBinding.ensureInitialized();
                          runApp(const MaterialApp(home: CircularProgressIndicator()));
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
        print('   Language: ${languageProvider.currentLanguageCode}');

        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            // Check if still loading
            if (settingsProvider.isLoading) {
              print('⏳ Settings still loading...');
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
                          'Loading settings...',
                          style: Theme.of(context).textTheme.titleMedium,
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

            return MaterialApp(
              title: settingsProvider.restaurantName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              locale: languageProvider.currentLocale,
              supportedLocales: languageProvider.supportedLocales,
              initialRoute: AppRoutes.menu,
              onGenerateRoute: AppRoutes.generateRoute,
            );
          },
        );
      },
    );
  }
}
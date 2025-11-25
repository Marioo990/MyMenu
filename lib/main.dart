import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_menu/screens/admin/admin_login_screen.dart';
import 'package:restaurant_menu/services/google_auth_service.dart';

import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';

// Providers
import 'providers/menu_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';

// Services
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/database_initializer.dart';

// Screens - Public
import 'screens/public/menu_screen.dart';
import 'screens/public/item_detail_screen.dart';
import 'screens/public/info_screen.dart';

// Screens - Admin
import 'screens/admin/google_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_items_screen.dart';
import 'screens/admin/manage_categories_screen.dart';
import 'screens/admin/manage_notifications_screen.dart';
import 'screens/admin/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  try {
    // Initialize Firebase
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

    // Enable offline persistence
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
        final settingsReady = !settingsProvider.isLoading;

        print('📊 Provider status:');
        print('   - Language ready: $languageReady (locale: ${languageProvider.currentLocale})');
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

        // Get values ONCE
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

        print('📱 Building MaterialApp: Title=$appTitle, Locale=$currentLocale');

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
            print('🌍 Locale resolution: system=$locale, supported=${supportedLocales.map((l) => l.languageCode).toList()}');

            // Zabezpieczenie - zawsze zwróć coś non-null
            if (supportedLocales.isEmpty) {
              print('⚠️ No supported locales! Using en-US fallback');
              return const Locale('en', 'US');
            }

            if (locale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  print('✅ Matched locale: ${supportedLocale.languageCode}');
                  return supportedLocale;
                }
              }
            }

            print('✅ Using first supported locale: ${supportedLocales.first.languageCode}');
            return supportedLocales.first;
          },
          home: const MenuScreen(),
          onGenerateRoute: _generateRoute,
        );
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    print('🧭 [_generateRoute] Called with route: ${settings.name}');
    print('🧭 [_generateRoute] Arguments: ${settings.arguments}');


    try {
      switch (settings.name) {
        case '/':
          print('🏠 [_generateRoute] Building MenuScreen route');
          return MaterialPageRoute(
            builder: (_) => const MenuScreen(),
            settings: settings,
          );

        case '/info':
          return MaterialPageRoute(
            builder: (_) => const InfoScreen(),
            settings: settings,
          );

        case '/item':
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['itemId'] != null) {
            return MaterialPageRoute(
              builder: (_) => ItemDetailScreen(itemId: args['itemId']),
              settings: settings,
            );
          }
          return _errorRoute();

        case '/admin':
        case '/admin/login':
          return MaterialPageRoute(
            builder: (_) => const AdminLoginScreen(),
            settings: settings,
          );

        case '/admin/dashboard':
          return MaterialPageRoute(
            builder: (_) => AdminGuard(
              child: const AdminDashboardScreen(),
            ),
            settings: settings,
          );

        case '/admin/items':
          return MaterialPageRoute(
            builder: (_) => AdminGuard(
              child: const ManageItemsScreen(),
            ),
            settings: settings,
          );

        case '/admin/categories':
          return MaterialPageRoute(
            builder: (_) => AdminGuard(
              child: const ManageCategoriesScreen(),
            ),
            settings: settings,
          );

        case '/admin/notifications':
          return MaterialPageRoute(
            builder: (_) => AdminGuard(
              child: const ManageNotificationsScreen(),
            ),
            settings: settings,
          );

        case '/admin/settings':
          return MaterialPageRoute(
            builder: (_) => AdminGuard(
              child: const SettingsScreen(),
            ),
            settings: settings,
          );

        default:
          print('⚠️ Unknown route: ${settings.name}');
          return _errorRoute();
      }
    } catch (e, stackTrace) {
      print('❌ Error generating route: $e');
      print('Stack trace: $stackTrace');
      return _errorRoute();
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}

// Admin Guard Widget
class AdminGuard extends StatefulWidget {
  final Widget child;

  const AdminGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  final GoogleAuthService _authService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Sprawdź email verification
          if (!user.emailVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _authService.signOut();
                Navigator.pushReplacementNamed(context, '/admin/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email not verified. Please verify your Google account.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
            return const Scaffold(
              body: Center(
                child: Text('Email verification required'),
              ),
            );
          }

          // Check admin role
          return FutureBuilder<bool>(
            future: _authService.checkAdminAccess(user),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (adminSnapshot.hasData && adminSnapshot.data == true) {
                // User is admin
                return widget.child;
              }

              // Not an admin - sign out and redirect
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (mounted) {
                  await _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/admin/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Access denied. Admin privileges required.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });

              return const Scaffold(
                body: Center(
                  child: Text('Unauthorized Access'),
                ),
              );
            },
          );
        }

        // Not logged in - redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/admin/login');
          }
        });

        return const Scaffold(
          body: Center(
            child: Text('Please sign in'),
          ),
        );
      },
    );
  }
}

// Error App for initialization failures
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
                        // Restart app
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
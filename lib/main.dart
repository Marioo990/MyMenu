import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'providers/restaurant_provider.dart';

// Services
import 'services/firebase_service.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/admin/admin_login_screen.dart'; // Import potrzebny dla home:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseService = FirebaseService();
    final authService = AuthService();

    // Próba włączenia offline persistence (ignorujemy błędy w web)
    try {
      await firebaseService.enableOfflinePersistence();
    } catch (e) {
      print('Offline persistence info: $e');
    }

    runApp(
      MultiProvider(
        providers: [
          Provider<FirebaseService>.value(value: firebaseService),
          Provider<AuthService>.value(value: authService),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => RestaurantProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider(firebaseService)),
          ChangeNotifierProvider(create: (_) => MenuProvider(firebaseService)),
        ],
        child: const RestaurantMenuApp(),
      ),
    );
  } catch (e) {
    print('Critical Init Error: $e');
    runApp(const ErrorApp());
  }
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, SettingsProvider>(
      builder: (context, languageProvider, settingsProvider, _) {
        // 1. Zabezpieczenie przed ładowaniem
        if (languageProvider.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // 2. SZTYWNE ZABEZPIECZENIE (To naprawia błąd "Unexpected null value")
        // Jeśli provider zwróci null lub pustą listę, używamy sztywnych danych.
        final supportedLocales = (languageProvider.supportedLocales.isNotEmpty)
            ? languageProvider.supportedLocales
            : [const Locale('en', 'US')];

        final currentLocale = languageProvider.currentLocale ?? supportedLocales.first;

        return MaterialApp(
          // Tytuł pobieramy bezpiecznie
          title: settingsProvider.restaurantName.isNotEmpty
              ? settingsProvider.restaurantName
              : 'Smart Menu',

          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Locale
          locale: currentLocale,
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) return supported;
              }
            }
            return supportedLocales.first;
          },

          // Routing
          onGenerateRoute: AppRoutes.generateRoute,
          // WAŻNE: Jeśli nie ma trasy początkowej, Flutter zgłupieje.
          // Ustawiamy ekran startowy (zazwyczaj Admin Login lub Menu w zależności od logiki)
          home: const AdminLoginScreen(),
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Błąd krytyczny aplikacji. Sprawdź konsolę.")),
      ),
    );
  }
}
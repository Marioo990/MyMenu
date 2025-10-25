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

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  final firebaseService = FirebaseService();
  final authService = AuthService();

  // Enable offline persistence for Firestore
  await firebaseService.enableOfflinePersistence();

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => SettingsProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const RestaurantMenuApp(),
    ),
  );
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
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
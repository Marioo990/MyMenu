import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color accentColor = Color(0xFFE74C3C);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Elevations
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Breakpoints
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),

    textTheme: _buildTextTheme(Brightness.light),
    // Typography
    // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
    //   displayLarge: GoogleFonts.poppins(
    //     fontSize: 32,
    //     fontWeight: FontWeight.bold,
    //     color: textPrimary,
    //   ),
    //   displayMedium: GoogleFonts.poppins(
    //     fontSize: 28,
    //     fontWeight: FontWeight.bold,
    //     color: textPrimary,
    //   ),
    //   displaySmall: GoogleFonts.poppins(
    //     fontSize: 24,
    //     fontWeight: FontWeight.bold,
    //     color: textPrimary,
    //   ),
    //   headlineLarge: GoogleFonts.poppins(
    //     fontSize: 20,
    //     fontWeight: FontWeight.w600,
    //     color: textPrimary,
    //   ),
    //   headlineMedium: GoogleFonts.poppins(
    //     fontSize: 18,
    //     fontWeight: FontWeight.w600,
    //     color: textPrimary,
    //   ),
    //   headlineSmall: GoogleFonts.poppins(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w600,
    //     color: textPrimary,
    //   ),
    //   bodyLarge: GoogleFonts.inter(
    //     fontSize: 16,
    //     fontWeight: FontWeight.normal,
    //     color: textPrimary,
    //   ),
    //   bodyMedium: GoogleFonts.inter(
    //     fontSize: 14,
    //     fontWeight: FontWeight.normal,
    //     color: textPrimary,
    //   ),
    //   bodySmall: GoogleFonts.inter(
    //     fontSize: 12,
    //     fontWeight: FontWeight.normal,
    //     color: textSecondary,
    //   ),
    //   labelLarge: GoogleFonts.inter(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w500,
    //     color: textPrimary,
    //   ),
    //   labelMedium: GoogleFonts.inter(
    //     fontSize: 12,
    //     fontWeight: FontWeight.w500,
    //     color: textPrimary,
    //   ),
    //   labelSmall: GoogleFonts.inter(
    //     fontSize: 10,
    //     fontWeight: FontWeight.w500,
    //     color: textSecondary,
    //   ),
    // ),

    // Components
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      iconTheme: IconThemeData(color: textPrimary),
    ),

    // Fixed: Changed CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: elevationS,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      elevation: 0,
      pressElevation: elevationS,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        side: const BorderSide(color: textLight, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: textLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: textLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: elevationL,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: const DividerThemeData(
      color: textLight,
      thickness: 1,
      space: 0,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: Color(0xFF1A1A1A),
      surface: Color(0xFF2C2C2C),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF2C2C2C),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Fixed: Changed CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: const Color(0xFF2C2C2C),
    ),
  );

  // Helper Methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(spacingM);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(spacingL);
    } else {
      return const EdgeInsets.all(spacingXL);
    }
  }
  // Helper method to build text theme with error handling
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    final textColor = brightness == Brightness.light ? textPrimary : Colors.white;
    final secondaryTextColor = brightness == Brightness.light ? textSecondary : Colors.white70;

    return baseTheme.copyWith(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }
}

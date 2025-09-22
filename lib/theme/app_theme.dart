import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef FontBuilder =
    TextStyle Function({
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
    });

class AppColors {
  static const Color primary = Color(0xFF2BBBAD);
  static const Color primaryLight = Color(0xFF4DCABD);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);

}

ThemeData buildLightTheme(FontBuilder font) {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textLight,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: base.textTheme.copyWith(
      titleLarge: font(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: AppColors.textLight,
      ),
      titleMedium: font(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.textLight,
      ),
      bodyMedium: font(fontSize: 16, color: AppColors.textLight),
      bodySmall: font(
        fontSize: 14,
        color: AppColors.textLight.withOpacity(0.8),
      ),
      labelLarge: font(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: font(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size.fromHeight(58),
        textStyle: font(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: base.iconTheme.copyWith(color: AppColors.textLight, size: 24),
    dividerTheme: base.dividerTheme.copyWith(
      color: AppColors.textLight.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight.withOpacity(0.6),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundLight,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}

ThemeData buildDarkTheme(FontBuilder font) {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: base.textTheme.copyWith(
      titleLarge: font(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: AppColors.textDark,
      ),
      titleMedium: font(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.textDark,
      ),
      bodyMedium: font(fontSize: 16, color: AppColors.textDark),
      bodySmall: font(fontSize: 14, color: AppColors.textDark.withOpacity(0.8)),
      labelLarge: font(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        letterSpacing: 0.5,
        color: AppColors.textDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: font(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size.fromHeight(58),
        textStyle: font(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: base.iconTheme.copyWith(color: AppColors.textDark, size: 24),
    dividerTheme: base.dividerTheme.copyWith(
      color: AppColors.textDark.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textDark.withOpacity(0.6),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundDark,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
  );
}

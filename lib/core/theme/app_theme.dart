import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.leakukuGreen,
      onPrimary: AppColors.white,
      secondary: AppColors.harvestGold,
      onSecondary: AppColors.earthCharcoal,
      error: AppColors.errorRed,
      onError: AppColors.white,
      surface: AppColors.farmCream,
      onSurface: AppColors.earthCharcoal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.farmCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.leakukuGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.leakukuGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.softGray.withValues(alpha: 0.2),
          disabledForegroundColor: AppColors.softGray,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.leakukuGreen,
          side: const BorderSide(color: AppColors.leakukuGreen),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        labelStyle: const TextStyle(color: AppColors.softGray),
        hintStyle: const TextStyle(color: AppColors.softGray),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIconColor: AppColors.leakukuGreen,
        suffixIconColor: AppColors.leakukuGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softGray.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.leakukuGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1.2,
        shadowColor: AppColors.softGray.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.leakukuGreen,
        foregroundColor: AppColors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.leakukuGreen.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.leakukuGreen);
          }
          return const IconThemeData(color: AppColors.softGray);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.leakukuGreen,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: AppColors.softGray);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.leakukuGreen,
        unselectedItemColor: AppColors.softGray,
        selectedIconTheme: IconThemeData(color: AppColors.leakukuGreen),
        unselectedIconTheme: IconThemeData(color: AppColors.softGray),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.earthCharcoal,
        contentTextStyle: const TextStyle(color: AppColors.white),
        actionTextColor: AppColors.harvestGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

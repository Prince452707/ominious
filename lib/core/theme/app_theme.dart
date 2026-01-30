import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF0055); 
  static const primaryDark = Color(0xFFD90048);
  static const primaryLight = Color(0xFFFF3377);

  static const secondary = Color(0xFFFFD700); 
  static const secondaryDark = Color(0xFFCCAC00);
  static const secondaryLight = Color(0xFFFFDF33);

  static const accent = Color(0xFF00FFCC); 
  static const accentDark = Color(0xFF00CC99);
  static const accentLight = Color(0xFF33FFDD);

  static const background = Color(0xFF0F1115); 
  static const surface = Color(0xFF1B1E23); 
  static const surfaceLight = Color(0xFF2A2F36);
  static const surfaceVariant = Color(0xFF3A3F47);

  static const error = Color(0xFFFF0033);
  static const success = Color(0xFF00FF88);
  static const warning = Color(0xFFFFBB00);

  static const textPrimary = Color(0xFFF0F2F5);
  static const textSecondary = Color(0xFF94A3B8);
  static const textTertiary = Color(0xFF64748B);

  static const divider = Color(0xFF2D3748);

  static const gradientStart = Color(0xFFFF0055);
  static const gradientMiddle = Color(0xFFFFD700);
  static const gradientEnd = Color(0xFF00FFCC);

  static const shimmerBase = Color(0xFF1B1E23);
  static const shimmerHighlight = Color(0xFF2A2F36);

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static LinearGradient get surfaceGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceLight],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
    );
  }
}

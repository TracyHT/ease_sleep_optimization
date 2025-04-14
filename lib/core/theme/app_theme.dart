import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../styles/text_styles.dart';
import '../styles/input_styles.dart';
import '../styles/button_styles.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: AppInputStyles.inputDecorationTheme,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary,
    ),
    textButtonTheme: TextButtonThemeData(style: AppButtonStyles.text),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlined,
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
      iconTheme: const IconThemeData(color: AppColors.white),
      centerTitle: true,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    inputDecorationTheme: AppInputStyles.inputDecorationThemeDark,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary.copyWith(
        backgroundColor: WidgetStateProperty.all(AppColors.secondary),
        foregroundColor: WidgetStateProperty.all(AppColors.black),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppButtonStyles.text.copyWith(
        foregroundColor: WidgetStateProperty.all(AppColors.secondary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlined.copyWith(
        foregroundColor: WidgetStateProperty.all(AppColors.secondary),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.secondary),
        ),
      ),
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.white,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.white,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.white,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
      iconTheme: const IconThemeData(color: AppColors.white),
      centerTitle: true,
    ),
  );
}

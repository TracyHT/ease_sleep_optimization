import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../styles/input_styles.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: AppInputStyles.inputDecorationTheme,
  );
}

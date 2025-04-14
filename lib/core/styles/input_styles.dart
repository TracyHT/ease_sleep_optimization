import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacings.dart';

class AppInputStyles {
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    contentPadding: AppSpacing.mediumPadding,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
      borderSide: BorderSide(color: AppColors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
      borderSide: BorderSide(color: AppColors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
      borderSide: BorderSide(color: AppColors.error),
    ),
    errorStyle: TextStyle(color: AppColors.error),
    labelStyle: TextStyle(color: AppColors.grey),
    hintStyle: TextStyle(color: AppColors.grey),
  );

  static final InputDecorationTheme inputDecorationThemeDark =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: AppSpacing.mediumPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.small),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.small),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.small),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.small),
          borderSide: BorderSide(color: AppColors.error),
        ),
        errorStyle: TextStyle(color: AppColors.error),
        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
      );
}

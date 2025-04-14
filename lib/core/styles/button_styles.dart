import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacings.dart';
import '../styles/text_styles.dart';

class AppButtonStyles {
  // Primary Button Style
  static final primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.small,
    ),
    textStyle: AppTextStyles.labelLarge,
    minimumSize: const Size(double.infinity, 48),
    elevation: 2,
  );

  // Secondary Button Style
  static final secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.small,
    ),
    textStyle: AppTextStyles.labelLarge,
    minimumSize: const Size(double.infinity, 48),
    elevation: 2,
  );

  // Text Button Style
  static final text = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.labelMedium,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.small,
    ),
  );

  // Outlined Button Style
  static final outlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.small),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.small,
    ),
    textStyle: AppTextStyles.labelMedium,
    minimumSize: const Size(double.infinity, 48),
  );
}

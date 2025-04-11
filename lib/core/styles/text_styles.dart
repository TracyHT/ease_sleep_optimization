import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(fontSize: 16, color: AppColors.textPrimary);

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

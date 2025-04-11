import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppInputStyles {
  static const inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: AppColors.textSecondary),
  );
}

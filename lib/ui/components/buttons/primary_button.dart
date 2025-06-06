import 'package:flutter/material.dart';
import '../../../core/styles/button_styles.dart';
import '../../../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppButtonStyles.primary.copyWith(
        // Tùy chỉnh minimumSize nếu không full-width
        minimumSize:
            isFullWidth
                ? WidgetStateProperty.all(const Size(double.infinity, 48))
                : WidgetStateProperty.all(const Size(120, 48)),
        // Tùy chỉnh màu khi disabled
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey.withOpacity(0.5);
          }
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey;
          }
          return AppColors.white;
        }),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
              : Text(text),
    );
  }
}

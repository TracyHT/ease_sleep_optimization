import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class MiddleFABButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const MiddleFABButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: isSelected ? AppColors.primary : Colors.grey,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.bed),
        ),
        const SizedBox(height: 4),
        Text(
          AppTexts.sleep, // Custom label
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

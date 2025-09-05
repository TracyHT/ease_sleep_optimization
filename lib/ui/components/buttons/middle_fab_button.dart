import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_strings.dart';

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
    final theme = Theme.of(context);
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSecondary = theme.colorScheme.onSecondary;

    return Column(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: secondaryColor,
          foregroundColor: onSecondary,
          elevation: isSelected ? 8 : 4,
          shape: const CircleBorder(),
          child: const Icon(Iconsax.moon5),
        ),
        const SizedBox(height: 4),
        Text(
          AppTexts.sleep,
          style: TextStyle(
            color:
                isSelected
                    ? secondaryColor
                    : theme.colorScheme.onBackground.withOpacity(0.5),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

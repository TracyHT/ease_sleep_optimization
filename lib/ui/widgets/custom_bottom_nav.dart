import 'package:ease_sleep_optimization/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/bottom_nav_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // notch cho FAB
      notchMargin: 6,
      color: AppColors.neutral900,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.bar_chart, AppTexts.statistics, 0, currentIndex, ref),
            _buildNavItem(Icons.healing, AppTexts.sleepAids, 1, currentIndex, ref),
            _buildNavItem(Icons.bed, AppTexts.sleep, 2, currentIndex, ref, hideIcon: true),
            _buildNavItem(Icons.power, AppTexts.control, 3, currentIndex, ref),
            _buildNavItem(Icons.settings, AppTexts.settings, 4, currentIndex, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
    WidgetRef ref, {
    bool hideIcon = false,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hideIcon
                ? const SizedBox(height: 24) // để label Sleep thẳng hàng
                : Icon(icon, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
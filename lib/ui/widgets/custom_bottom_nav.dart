import 'package:ease_sleep_optimization/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
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
            _buildNavItem(
              Iconsax.chart5,
              AppTexts.statistics,
              0,
              currentIndex,
              ref,
            ),
            _buildNavItem(
              Iconsax.heart5,
              AppTexts.sleepAids,
              1,
              currentIndex,
              ref,
            ),
            _buildNavItem(
              Iconsax.moon5,
              AppTexts.sleep,
              2,
              currentIndex,
              ref,
              hideIcon: true,
            ),
            _buildNavItem(
              Iconsax.setting_45,
              AppTexts.control,
              3,
              currentIndex,
              ref,
            ),
            _buildNavItem(
              Iconsax.setting_2,
              AppTexts.settings,
              4,
              currentIndex,
              ref,
            ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            hideIcon
                ? const SizedBox(height: 24) // để label Sleep thẳng hàng
                : Container(
                  height: 24,
                  width: 24,
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white54,
                    size: 22,
                  ),
                ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

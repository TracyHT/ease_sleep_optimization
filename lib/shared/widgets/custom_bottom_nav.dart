import 'package:ease_sleep_optimization/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/bottom_nav_provider.dart';
import '../../ui/components/buttons/middle_fab_button.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // 1. The fixed-height SizedBox has been removed.
    return Stack(
      // 2. Allow the FAB to draw outside the Stack's bounds.
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter, // Helps align positioned children
      children: [
        // This is the bottom layer (the nav bar itself)
        _buildBottomNavigationBar(ref, currentIndex),

        // 3. Reposition the FAB to sit on top of the navigation bar.
        // We use a negative 'top' value to push it upwards.
        Positioned(
          top: -30, // Adjust this value to control how high the button sits
          child: MiddleFABButton(
            isSelected: currentIndex == 2,
            onTap: () {
              if (currentIndex != 2) {
                ref.read(bottomNavIndexProvider.notifier).state = 2;
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int currentIndex) {
    // This widget remains unchanged.
    return Theme(
      data: Theme.of(ref.context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: AppColors.primary800,
        selectedItemColor: AppColors.primary,
        onTap: (index) {
          if (index != 2) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppTexts.statistics,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: AppTexts.sleep_aids,
          ),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.power),
            label: AppTexts.control,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppTexts.settings,
          ),
        ],
      ),
    );
  }
}

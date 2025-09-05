import 'package:ease_sleep_optimization/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/bottom_nav_provider.dart';
import 'middle_fab_button.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _buildBottomNavigationBar(ref, currentIndex),

          Positioned(
            bottom: 5,
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
      ),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int currentIndex) {
    return Theme(
      data: Theme.of(ref.context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
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
            label: AppTexts.sleepAids,
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

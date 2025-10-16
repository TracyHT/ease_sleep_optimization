import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/providers/bottom_nav_provider.dart';
import './settings/screens/settings_screen.dart';
import './statistics/screens/statistics_screen.dart';
import './control/screens/controls_screen.dart';
import './sleep_aids/screens/sleep_aids_screens.dart';
import './sleep_mode/screens/sleep_mode_screen.dart';
import '../shared/widgets/custom_bottom_nav.dart';

class NavigationWrapper extends ConsumerWidget {
  const NavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    final screens = [
      const StatisticsScreen(),
      const SleepaidsScreens(),
      const SleepModeScreen(),
      const ControlsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[index],

      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/bottom_nav_provider.dart';
import './settings/screens/settings_screen.dart';
import './statistics/screens/statistics_screen.dart';
import './control/screens/control_screen.dart';
import './sleepAids/screens/sleepAids_screens.dart';
import './sleepMode/screens/sleepMode_screen.dart';
import '../ui/widgets/custom_bottom_nav.dart';

class NavigationWrapper extends ConsumerWidget {
  const NavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    final screens = [
      const StatisticsScreen(),
      const SleepaidsScreens(),
      const SleepmodeScreen(),
      const ControlScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

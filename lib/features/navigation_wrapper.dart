import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/providers/bottom_nav_provider.dart';
import './settings/screens/settings_screen.dart';
import './statistics/screens/statistics_screen.dart';
import './control/screens/controls_screen.dart';
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
      const SleepModeScreen(),
      const ControlsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
  body: screens[index],
  bottomNavigationBar: const CustomBottomNavBar(),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  floatingActionButton: Padding(
    padding: const EdgeInsets.only(bottom: 10), 
    child: FloatingActionButton(
      onPressed: () {
        ref.read(bottomNavIndexProvider.notifier).state = 2;
      },
      shape: const CircleBorder(),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      elevation: index == 2 ? 8 : 4,
      child: const Icon(Iconsax.moon5),
    ),
  ),
);


  }
}

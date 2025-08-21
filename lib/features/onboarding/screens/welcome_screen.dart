import 'package:ease_sleep_optimization/core/styles/button_styles.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../ui/components/buttons/primary_button.dart';
import '../../statistics/screens/statistics_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppSpacing.screenEdgePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Welcome to Ease!',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(width: AppSpacing.small),
                Icon(Icons.star, color: AppColors.accent, size: 24),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Description text about something on this page that can be long or short.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.large),
            PrimaryButton(
              text: 'Get Started',
              onPressed: () {
                // Navigate to StatisticsScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () {
                // Navigate to StatisticsScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
              style: AppButtonStyles.secondary,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

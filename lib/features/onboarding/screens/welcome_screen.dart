import 'package:ease_sleep_optimization/core/styles/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../ui/components/buttons/primary_button.dart';
import '../../../ui/components/gradient_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenEdgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // App Illustration
                Center(
                  child: Image.asset(
                    'lib/assets/images/illustration.png',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),

                const SizedBox(height: AppSpacing.small),

                // Main Heading
                Text(
                  'Find your calm \nwith Ease',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: AppSpacing.small),

                // Description
                Text(
                  'Personalized insights and sleep aids to help you rest better.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),

                const Spacer(flex: 1),

                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      text: 'Get Started',
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: AppButtonStyles.secondary.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.primary,
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(color: colorScheme.primary, width: 1),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

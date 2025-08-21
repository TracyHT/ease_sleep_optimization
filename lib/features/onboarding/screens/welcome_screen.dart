import 'package:ease_sleep_optimization/core/styles/button_styles.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../ui/components/buttons/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenEdgePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // App Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: colorScheme.primary,
                  size: 64,
                ),
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // Main Heading
              Text(
                'Welcome to Ease',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.small),
              
              // Subheading
              Text(
                'Sleep Optimization',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                child: Text(
                  'Transform your sleep with personalized insights, soothing sleep aids, and comprehensive tracking to help you achieve better rest every night.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const Spacer(flex: 3),
              
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
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      foregroundColor: WidgetStateProperty.all(colorScheme.primary),
                      side: WidgetStateProperty.all(
                        BorderSide(color: colorScheme.primary, width: 1),
                      ),
                    ),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

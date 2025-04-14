import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../ui/components/buttons/primary_button.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: AppSpacing.screenEdgePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('This is Statistics Screen')),
            const SizedBox(height: AppSpacing.medium),
            PrimaryButton(
              text: 'Submit',
              onPressed: () {
                print('Submit button pressed');
              },
            ),
          ],
        ),
      ),
    );
  }
}

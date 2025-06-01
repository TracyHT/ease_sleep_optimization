import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacings.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/sleep_summary_widget.dart';
import '../providers/sleep_data_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepDataAsync = ref.watch(sleepDataProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.screenEdgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Trend',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02), // ~5-8 pixels
                DatePickerWidget(),

                SizedBox(height: screenHeight * 0.02),
                sleepDataAsync.when(
                  data: (data) => SleepSummaryWidget(data: data),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading data: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

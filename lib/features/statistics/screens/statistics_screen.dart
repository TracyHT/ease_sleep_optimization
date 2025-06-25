import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacings.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/sleep_summary_widget.dart';
import '../widgets/sleep_stage_chart_widget.dart';
import '../providers/sleep_data_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepDataAsync = ref.watch(sleepDataProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: AppSpacing.screenEdgePadding.left,
            right: AppSpacing.screenEdgePadding.right,
            bottom: AppSpacing.screenEdgePadding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Trend',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              const DatePickerWidget(),

              SizedBox(height: screenHeight * 0.03),

              sleepDataAsync.when(
                data: (data) => SleepSummaryWidget(data: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Text(
                      'Error loading data: $e',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
              ),

              const SizedBox(height: 24),

              SleepStageChartWidget.mock(),

              const SizedBox(height: 32),

              Text(
                "What happened last night?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _timelineItem(
                        context,
                        "22:15",
                        "Sleep initiated",
                        "EEG shows alpha-to-theta transition.",
                      ),
                      _timelineItem(
                        context,
                        "23:15",
                        "Room too warm (28°C)",
                        "Fan auto turned on via IoT integration.",
                      ),
                      _timelineItem(
                        context,
                        "01:45",
                        "Entered Deep Sleep",
                        "Dominant delta waves detected.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineItem(
    BuildContext context,
    String time,
    String title,
    String desc,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$time — $title",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

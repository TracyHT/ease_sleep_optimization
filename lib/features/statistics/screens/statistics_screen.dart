import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacings.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/sleep_summary_widget.dart';
import '../widgets/sleep_stage_chart_widget.dart';
import '../providers/sleep_data_provider.dart';
import '../providers/selected_date_provider.dart';
import '../../../services/statistics_data_service.dart';
import '../../../services/local_database_service.dart';
import '../../../ui/components/section_heading.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Refresh all data
                      ref.invalidate(sleepDataProvider);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Refresh data',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SectionHeading(
                title: "Today",
                nav: "Trend",
                onTap: () {
                  // Navigate to detailed statistics screen
                },
              ),

              const DatePickerWidget(),

              SizedBox(height: screenHeight * 0.03),

              sleepDataAsync.when(
                data: (data) {
                  if (data == null) {
                    return _buildNoDataWidget(context, ref);
                  }
                  return SleepSummaryWidget(data: data);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  'Error loading data: $e',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final selectedDate = ref.watch(selectedDateProvider);
                  return FutureBuilder<Widget>(
                    future: _buildSleepStageChart(selectedDate),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return snapshot.data ?? SleepStageChartWidget.mock();
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              Consumer(
                builder: (context, ref, child) {
                  final selectedDate = ref.watch(selectedDateProvider);
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getEnvironmentalTimeline(selectedDate),
                    builder: (context, snapshot) {
                      return _buildTimelineSection(
                        context,
                        snapshot.data ?? [],
                        snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: AppSpacing.largePadding,
        child: Column(
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No sleep data for this date',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Try generating sample data from the Database Test screen in Settings to see statistics.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/database-test');
                    },
                    icon: const Icon(Icons.science),
                    label: const Text('Generate Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Force refresh by invalidating the provider
                      ref.invalidate(sleepDataProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> _buildSleepStageChart(DateTime selectedDate) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return SleepStageChartWidget.mock();
    }

    try {
      // Get sleep sessions for the selected date
      final sessions = LocalDatabaseService.getUserSleepSessions(currentUser.uid)
          .where((session) {
        final startTime = DateTime.parse(session['startTime'] ?? '');
        return startTime.year == selectedDate.year &&
               startTime.month == selectedDate.month &&
               startTime.day == selectedDate.day;
      }).toList();

      if (sessions.isEmpty) {
        return SleepStageChartWidget.mock();
      }

      // Get sleep stage scoring for the main session
      final mainSession = sessions.first;
      final sessionId = mainSession['sessionId'] as int;
      final startTime = DateTime.parse(mainSession['startTime'] ?? '');
      final stageScoring = LocalDatabaseService.getSleepStageScoring(sessionId);

      if (stageScoring.isEmpty) {
        return SleepStageChartWidget.mock();
      }

      return SleepStageChartWidget.fromDatabase(
        stageScoring: stageScoring,
        startTime: startTime,
      );
    } catch (e) {
      print('Error building sleep stage chart: $e');
      return SleepStageChartWidget.mock();
    }
  }

  Future<List<Map<String, dynamic>>> _getEnvironmentalTimeline(DateTime selectedDate) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      // Get sleep sessions for the selected date
      final sessions = LocalDatabaseService.getUserSleepSessions(currentUser.uid)
          .where((session) {
        final startTime = DateTime.parse(session['startTime'] ?? '');
        return startTime.year == selectedDate.year &&
               startTime.month == selectedDate.month &&
               startTime.day == selectedDate.day;
      }).toList();

      if (sessions.isEmpty) return [];

      // Get timeline for the main session
      final mainSession = sessions.first;
      final sessionId = mainSession['sessionId'] as int;
      
      return StatisticsDataService.getEnvironmentalTimeline(sessionId);
    } catch (e) {
      print('Error getting environmental timeline: $e');
      return [];
    }
  }

  Widget _buildTimelineSection(
    BuildContext context,
    List<Map<String, dynamic>> timeline,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What happened last night?",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (timeline.isEmpty)
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: AppSpacing.mediumPadding,
              child: Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      'No environmental events detected\nYour sleep environment was optimal!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: timeline.map((event) {
                  final eventTime = event['time'] as DateTime;
                  final timeString = '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}';
                  
                  return _timelineItem(
                    context,
                    timeString,
                    event['event'] ?? 'Unknown event',
                    event['description'] ?? '',
                  );
                }).toList(),
              ),
            ),
          ),
      ],
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
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
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

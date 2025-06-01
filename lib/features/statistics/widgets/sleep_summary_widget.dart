import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/sleep_summary_data.dart';

class SleepSummaryWidget extends StatelessWidget {
  final SleepSummaryData data;

  const SleepSummaryWidget({super.key, required this.data});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${twoDigits(hours)}h ${twoDigits(minutes)}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    final pieData = {
      'Efficiency': data.efficiency.toDouble(),
      'Inefficiency': (100 - data.efficiency).toDouble(),
    };

    final pieColors = [
      colorScheme.primary,
      colorScheme.primary.withOpacity(0.3),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container with pie chart + summary inside
        Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SleepScoreCircle(score: data.score, size: screenHeight * 0.10),
              SizedBox(width: screenHeight * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDuration(data.totalSleep),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Total Sleep', style: textTheme.bodyMedium),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      '${data.efficiency}%',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Efficiency', style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.03),

        // The 3 metrics below the container, outside of it
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoColumn(
              label: 'Efficiency',
              value: '${data.efficiency}',
              valueStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              labelStyle: textTheme.bodySmall,
            ),
            _InfoColumn(
              label: 'Latency',
              value: '${data.latency} min',
              valueStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              labelStyle: textTheme.bodySmall,
            ),
            _InfoColumn(
              label: 'WASO',
              value: '${data.waso} min',
              valueStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              labelStyle: textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _SleepScoreCircle extends StatelessWidget {
  final int score;
  final double size;

  const _SleepScoreCircle({required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: size * 0.1,
            backgroundColor: colorScheme.primaryContainer.withOpacity(0.4),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        Text(
          '$score',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: valueStyle),
        SizedBox(height: 4),
        Text(label, style: labelStyle),
      ],
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/models/sleep_summary_data.dart';
import '../../../ui/components/buttons/secondary_button.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container with pie chart + summary inside
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  _SleepScoreCircle(
                    score: data.score,
                    size: screenHeight * 0.10,
                  ),
                  const SizedBox(height: 12),
                  Text('Sleep Score', style: textTheme.bodyMedium),
                ],
              ),

              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Sleep
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDuration(data.totalSleep),
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Total Sleep', style: textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Efficiency
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.efficiency}%',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Efficiency', style: textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: 'View Details',
                      onPressed: () {
                        // TODO: handle button press
                      },
                    ),
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

    // Determine color based on score
    Color getScoreColor() {
      if (score >= 80) {
        return colorScheme.primary; // Excellent - use primary color
      } else if (score >= 60) {
        return Colors.orange; // Good
      } else {
        return Colors.red; // Poor
      }
    }

    final scoreColor = getScoreColor();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: size * 0.1,
            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
        Text(
          '$score',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

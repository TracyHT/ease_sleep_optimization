import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SleepStageChartWidget extends StatelessWidget {
  final List<SleepStageData> data;

  const SleepStageChartWidget({super.key, required this.data});

  // Helper to add small random offset ±0.1 to stage values
  static double _variedStage(int stage) {
    final rand = Random();
    double offset = (rand.nextDouble() - 0.5) * 0.2; // from -0.1 to +0.1
    double varied = stage + offset;
    // Clamp to valid range 0 to 3
    return varied.clamp(0, 3);
  }

  // Mock data with 30-minute intervals and varied stage values for more natural curve
  factory SleepStageChartWidget.mock() {
    final now = DateTime.now();
    return SleepStageChartWidget(
      data:
          [
                SleepStageData(now, 3),
                SleepStageData(now.add(Duration(minutes: 30)), 2),
                SleepStageData(now.add(Duration(hours: 1)), 1),
                SleepStageData(now.add(Duration(hours: 1, minutes: 30)), 0),
                SleepStageData(now.add(Duration(hours: 2)), 1),
                SleepStageData(now.add(Duration(hours: 2, minutes: 30)), 1),
                SleepStageData(now.add(Duration(hours: 3)), 2),
                SleepStageData(now.add(Duration(hours: 3, minutes: 30)), 1),
                SleepStageData(now.add(Duration(hours: 4)), 0),
                SleepStageData(now.add(Duration(hours: 4, minutes: 30)), 1),
                SleepStageData(now.add(Duration(hours: 5)), 2),
                SleepStageData(now.add(Duration(hours: 5, minutes: 30)), 2),
                SleepStageData(now.add(Duration(hours: 6)), 1),
                SleepStageData(now.add(Duration(hours: 6, minutes: 30)), 0),
                SleepStageData(now.add(Duration(hours: 7)), 1),
                SleepStageData(now.add(Duration(hours: 7, minutes: 30)), 2),
                SleepStageData(now.add(Duration(hours: 8)), 3),
              ]
              .map((e) => SleepStageData(e.time, _variedStage(e.stage).toInt()))
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = data.first.time;
    final spots =
        data.map((e) {
          final diff = e.time.difference(startTime).inMinutes.toDouble() / 60;
          return FlSpot(diff, e.stage.toDouble());
        }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 8,
          minY: 0,
          maxY: 3,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const stageLabels = {
                    3: 'Awake',
                    2: 'REM',
                    1: 'Light',
                    0: 'Deep',
                  };
                  final label = stageLabels[value.toInt()] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(label, style: theme.textTheme.labelSmall),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value > 8) return Container();
                  final hourLabel = '${value.toInt()}h';
                  return Text(hourLabel, style: theme.textTheme.labelSmall);
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: theme.colorScheme.primary,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepStageData {
  final DateTime time;
  final int stage; // 3: Awake, 2: REM, 1: Light, 0: Deep

  SleepStageData(this.time, this.stage);
}

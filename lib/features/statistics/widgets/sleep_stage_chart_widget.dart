import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SleepStageChartWidget extends StatelessWidget {
  final List<SleepStageData> data;

  const SleepStageChartWidget({super.key, required this.data});


  // Create from sleep stage scoring data
  factory SleepStageChartWidget.fromDatabase({
    required List<Map<String, dynamic>> stageScoring,
    required DateTime startTime,
  }) {
    if (stageScoring.isEmpty) {
      return SleepStageChartWidget.mock(); // Fallback to mock data
    }

    final List<SleepStageData> chartData = [];
    
    // Sort scoring by epoch index
    final sortedScoring = List<Map<String, dynamic>>.from(stageScoring);
    sortedScoring.sort((a, b) => (a['epochIndex'] as int).compareTo(b['epochIndex'] as int));
    
    for (final scoring in sortedScoring) {
      final epochIndex = scoring['epochIndex'] as int;
      final sleepStage = scoring['sleepStage'] as String;
      
      // Convert sleep stage to numeric value for chart
      int stageValue;
      switch (sleepStage) {
        case 'Wake':
          stageValue = 4;
          break;
        case 'REM':
          stageValue = 3;
          break;
        case 'N1':
          stageValue = 2;
          break;
        case 'N2':
          stageValue = 1;
          break;
        case 'N3':
          stageValue = 0;
          break;
        default:
          stageValue = 1;
      }
      
      // Each epoch represents 30 seconds, convert to time
      final epochTime = startTime.add(Duration(seconds: epochIndex * 30));
      chartData.add(SleepStageData(epochTime, stageValue));
    }
    
    return SleepStageChartWidget(data: chartData);
  }

  // Mock data with date-specific variation and realistic sleep architecture
  factory SleepStageChartWidget.mock({DateTime? selectedDate}) {
    final baseDate = selectedDate ?? DateTime.now();
    
    // Use date as seed for consistent but different patterns per day
    final seed = baseDate.year * 10000 + baseDate.month * 100 + baseDate.day;
    final random = Random(seed);
    
    // Create realistic sleep architecture based on the date
    final sleepStart = DateTime(baseDate.year, baseDate.month, baseDate.day, 22, 30);
    
    return SleepStageChartWidget(
      data: _generateRealisticSleepPattern(sleepStart, random),
    );
  }
  
  // Generate realistic sleep pattern based on sleep science
  static List<SleepStageData> _generateRealisticSleepPattern(DateTime startTime, Random random) {
    final List<SleepStageData> data = [];
    final int totalMinutes = 480; // 8 hours
    const int intervalMinutes = 15; // 15-minute intervals for smoother chart
    
    // Sleep stages follow typical pattern:
    // 1. Initial wake period (5-15 min)
    // 2. N1/N2 light sleep (first 90 min cycle)
    // 3. Deep sleep N3 (30-60 min in first half)
    // 4. REM cycles (longer in second half)
    // 5. Brief awakenings
    
    int currentMinute = 0;
    
    while (currentMinute < totalMinutes) {
      final cyclePosition = (currentMinute % 90) / 90.0; // 90-min sleep cycles
      final sleepProgress = currentMinute / totalMinutes.toDouble();
      
      int stage;
      
      if (currentMinute < 15) {
        // Initial settling period
        stage = random.nextDouble() < 0.7 ? 4 : 2; // Mostly awake, some N1
      } else if (sleepProgress < 0.3) {
        // First third: Deep sleep more likely
        if (cyclePosition < 0.2) {
          stage = random.nextDouble() < 0.5 ? 2 : 1; // N1 or N2
        } else if (cyclePosition < 0.6) {
          stage = random.nextDouble() < 0.6 ? 0 : 1; // More N3 or N2
        } else {
          stage = random.nextDouble() < 0.3 ? 3 : 1; // Some REM or N2
        }
      } else if (sleepProgress < 0.8) {
        // Middle third: Mix of stages
        if (cyclePosition < 0.3) {
          stage = random.nextDouble() < 0.6 ? 1 : 2; // Mostly N2, some N1
        } else if (cyclePosition < 0.7) {
          stage = random.nextDouble() < 0.5 ? 3 : 1; // REM or N2
        } else {
          stage = random.nextDouble() < 0.2 ? 0 : 1; // Less N3, mostly N2
        }
      } else {
        // Final third: More REM and brief awakenings
        if (cyclePosition < 0.2) {
          stage = random.nextDouble() < 0.1 ? 4 : 2; // Brief awakenings or N1
        } else if (cyclePosition < 0.8) {
          stage = random.nextDouble() < 0.6 ? 3 : 2; // More REM or N1
        } else {
          stage = random.nextDouble() < 0.7 ? 1 : 2; // N2 or N1
        }
      }
      
      // Add some natural variation
      if (random.nextDouble() < 0.1) {
        stage = [0, 1, 2, 3, 4][random.nextInt(5)];
      }
      
      data.add(SleepStageData(
        startTime.add(Duration(minutes: currentMinute)),
        stage,
      ));
      
      currentMinute += intervalMinutes;
    }
    
    return data;
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
          maxY: 4,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const stageLabels = {
                    4: 'Awake',
                    3: 'REM',
                    2: 'N1',
                    1: 'N2',
                    0: 'N3',
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
  final int stage; // 4: Awake, 3: REM, 2: N1, 1: N2, 0: N3

  SleepStageData(this.time, this.stage);
}

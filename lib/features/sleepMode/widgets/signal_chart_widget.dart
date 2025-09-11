import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dynamic_chart_data.dart';

class SignalChartWidget extends StatefulWidget {
  final bool isActive;
  final String title;
  final List<String> channelNames;

  const SignalChartWidget({
    super.key,
    this.isActive = false,
    this.title = "Sleep Signals",
    this.channelNames = const ["Brain Activity", "Heart Rate", "Breathing"],
  });

  @override
  State<SignalChartWidget> createState() => _SignalChartWidgetState();
}

class _SignalChartWidgetState extends State<SignalChartWidget> {
  static const double windowLength = 2000;
  static const List<double> amplitudeList = [50, 100, 200];
  double currentAmplitude = amplitudeList[1];

  List<DynamicChartData> chartDataList = [];
  Timer? _simulationTimer;
  bool _isSimulating = false;

  final List<Color> channelColors = [
    Color(0xFF4E616D), // Brain Activity - Blue-gray
    Color(0xFF4E6D52), // Heart Rate - Green
    Color(0xFF6D6C4E), // Breathing - Yellow-brown
    Color(0xFF6D584E), // Additional - Brown
    Colors.deepPurple,
    Colors.teal,
    Colors.pinkAccent,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    initChannels();
    if (widget.isActive) {
      startSimulation();
    }
  }

  @override
  void didUpdateWidget(SignalChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        startSimulation();
      } else {
        stopSimulation();
      }
    }
  }

  void initChannels() {
    chartDataList.clear();
    for (int i = 0; i < widget.channelNames.length; i++) {
      chartDataList.add(DynamicChartData(windowLength)..start());
    }
    setState(() {});
  }

  void startSimulation() {
    if (_isSimulating) return;
    _isSimulating = true;
    
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!widget.isActive) {
        stopSimulation();
        return;
      }
      
      for (int i = 0; i < chartDataList.length; i++) {
        chartDataList[i].generateSimulatedData();
      }
      
      if (mounted) {
        setState(() {});
      }
    });
  }

  void stopSimulation() {
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    stopSimulation();
    for (var chartData in chartDataList) {
      chartData.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Iconsax.chart,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isActive ? "Active" : "Inactive",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amplitude Controls
          Row(
            children: [
              Text(
                "Amplitude:",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              SegmentedButton<double>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white70,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: colorScheme.primary,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                ),
                segments: [
                  for (final value in amplitudeList)
                    ButtonSegment(
                      value: value,
                      label: Text(value.toInt().toString()),
                    ),
                ],
                selected: {currentAmplitude},
                onSelectionChanged: (amp) => setState(() => currentAmplitude = amp.first),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Charts
          if (chartDataList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            for (int i = 0; i < widget.channelNames.length && i < chartDataList.length; i++) ...[
              buildChannelInfo(widget.channelNames[i], chartDataList[i], channelColors[i % channelColors.length]),
              const SizedBox(height: 8),
              buildChart(chartDataList[i], channelColors[i % channelColors.length]),
              if (i < widget.channelNames.length - 1) const SizedBox(height: 16),
            ],
          ],
          
          if (!widget.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  "Start sleep session to begin signal monitoring",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildChannelInfo(String name, DynamicChartData data, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          data.points.isNotEmpty 
              ? '${data.points.last.y.toStringAsFixed(1)} μV'
              : '-- μV',
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildChart(DynamicChartData data, Color color) {
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          maxY: currentAmplitude,
          minY: -currentAmplitude,
          minX: 0,
          maxX: windowLength,
          lineTouchData: const LineTouchData(enabled: false),
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: currentAmplitude / 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.points,
              show: data.points.isNotEmpty,
              dotData: const FlDotData(show: false),
              color: color,
              barWidth: 1.5,
              isCurved: false,
              isStrokeCapRound: true,
            )
          ],
          titlesData: const FlTitlesData(show: false),
        ),
      ),
    );
  }
}
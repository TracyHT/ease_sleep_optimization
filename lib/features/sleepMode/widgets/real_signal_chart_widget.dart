import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'dynamic_chart_data.dart';

class RealSignalChartWidget extends StatefulWidget {
  final BrainBit2? sensor;
  final bool isActive;
  final String title;
  final List<String> channelNames;

  const RealSignalChartWidget({
    super.key,
    this.sensor,
    this.isActive = false,
    this.title = "Sleep Signals",
    this.channelNames = const ["Brain Activity", "Heart Rate", "Breathing"],
  });

  @override
  State<RealSignalChartWidget> createState() => _RealSignalChartWidgetState();
}

class _RealSignalChartWidgetState extends State<RealSignalChartWidget> {
  static const double windowLength = 2000;
  static const List<double> amplitudeList = [50, 100, 200];
  double currentAmplitude = amplitudeList[1];

  List<FEEGChannelInfo?> channels = [];
  List<DynamicChartData> chartDataList = [];
  StreamSubscription? signalSubscription;
  Timer? _simulationTimer;
  bool _isSimulating = false;
  bool _isConnected = false;

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
      startMonitoring();
    }
  }

  @override
  void didUpdateWidget(RealSignalChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        startMonitoring();
      } else {
        stopMonitoring();
      }
    }
    
    if (widget.sensor != oldWidget.sensor) {
      initChannels();
      if (widget.isActive) {
        startMonitoring();
      }
    }
  }

  Future<void> initChannels() async {
    chartDataList.clear();
    
    if (widget.sensor != null) {
      try {
        channels = await widget.sensor!.supportedChannels.value;
        _isConnected = true;
      } catch (e) {
        print('Error getting channels: $e');
        channels = [];
        _isConnected = false;
      }
    } else {
      channels = [];
      _isConnected = false;
    }

    // Create chart data for available channels or fallback channels
    int channelCount = channels.isNotEmpty ? channels.length : widget.channelNames.length;
    for (int i = 0; i < channelCount; i++) {
      chartDataList.add(DynamicChartData(windowLength)..start());
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  void startMonitoring() {
    if (_isSimulating || signalSubscription != null) return;

    if (widget.sensor != null && _isConnected) {
      // Use real sensor data
      startRealSignalMonitoring();
    } else {
      // Fall back to simulation for testing
      startSimulation();
    }
  }

  void startRealSignalMonitoring() {
    try {
      signalSubscription = widget.sensor!.signalDataStream.listen(
        processRealSignals,
        onError: (error) {
          print('Signal stream error: $error');
          // Fall back to simulation on error
          signalSubscription?.cancel();
          signalSubscription = null;
          startSimulation();
        },
      );
      
      widget.sensor!.execute(FSensorCommand.startSignal);
      print('Started real signal monitoring');
    } catch (e) {
      print('Error starting real signals: $e');
      startSimulation();
    }
  }

  void processRealSignals(List<SignalChannelsData> event) {
    for (int i = 0; i < channels.length && i < chartDataList.length; i++) {
      final ch = channels[i];
      if (ch == null) continue;

      final samples = event[ch.num].samples;
      chartDataList[i].add(samples);
    }

    if (mounted) {
      setState(() {});
    }
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

  void stopMonitoring() {
    stopSimulation();
    stopRealSignals();
  }

  void stopSimulation() {
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void stopRealSignals() {
    signalSubscription?.cancel();
    signalSubscription = null;
    
    if (widget.sensor != null) {
      try {
        widget.sensor!.execute(FSensorCommand.stopSignal);
      } catch (e) {
        print('Error stopping signal: $e');
      }
    }
  }

  @override
  void dispose() {
    stopMonitoring();
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
                _isConnected ? Iconsax.activity : Iconsax.chart,
                color: _isConnected ? Colors.green : colorScheme.primary,
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
                  color: widget.isActive ? (_isConnected ? Colors.green : Colors.orange) : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.isActive ? (_isConnected ? Colors.green : Colors.orange) : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Connection Status
          Text(
            _isConnected ? "Real BrainBit Data" : "Simulated Data",
            style: theme.textTheme.bodySmall?.copyWith(
              color: _isConnected ? Colors.green : Colors.orange,
              fontStyle: FontStyle.italic,
            ),
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
            for (int i = 0; i < _getDisplayChannelNames().length && i < chartDataList.length; i++) ...[
              buildChannelInfo(_getDisplayChannelNames()[i], chartDataList[i], channelColors[i % channelColors.length]),
              const SizedBox(height: 8),
              buildChart(chartDataList[i], channelColors[i % channelColors.length]),
              if (i < _getDisplayChannelNames().length - 1) const SizedBox(height: 16),
            ],
          ],
          
          if (!widget.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  "Start monitoring to begin signal visualization",
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

  List<String> _getDisplayChannelNames() {
    if (channels.isNotEmpty) {
      return channels.map((ch) => ch?.name ?? "Unknown").toList();
    }
    return widget.channelNames;
  }

  String _getStatusText() {
    if (!widget.isActive) return "Inactive";
    if (_isConnected && signalSubscription != null) return "Live Data";
    if (_isSimulating) return "Simulated";
    return "Starting...";
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
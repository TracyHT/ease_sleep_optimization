import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/components/gradient_background.dart';
import '../widgets/signal_chart_widget.dart';

class BrainMonitoringScreen extends StatefulWidget {
  const BrainMonitoringScreen({super.key});

  @override
  State<BrainMonitoringScreen> createState() => _BrainMonitoringScreenState();
}

class _BrainMonitoringScreenState extends State<BrainMonitoringScreen> {
  bool _isMonitoring = false;
  String _sessionStatus = "Ready to start";
  DateTime? _sessionStartTime;

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        _sessionStartTime = DateTime.now();
        _sessionStatus = "Monitoring active";
      } else {
        _sessionStartTime = null;
        _sessionStatus = "Monitoring stopped";
      }
    });
  }

  String _getSessionDuration() {
    if (_sessionStartTime == null) return "00:00:00";
    final duration = DateTime.now().difference(_sessionStartTime!);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Brain Monitoring",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isMonitoring ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sessionStatus,
                          style: textTheme.titleMedium?.copyWith(
                            color: _isMonitoring ? Colors.green : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isMonitoring) ...[
                      Text(
                        "Session Duration",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          return Text(
                            _getSessionDuration(),
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Control Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isMonitoring ? Colors.red.shade600 : colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _toggleMonitoring,
                  icon: Icon(
                    _isMonitoring ? Iconsax.stop : Iconsax.play,
                    size: 20,
                  ),
                  label: Text(
                    _isMonitoring ? "Stop Monitoring" : "Start Monitoring",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Signal Charts
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Brain Activity Chart
                      SignalChartWidget(
                        isActive: _isMonitoring,
                        title: "EEG Brain Signals",
                        channelNames: const [
                          "Frontal Lobe",
                          "Parietal Lobe",
                          "Occipital Lobe",
                          "Temporal Lobe",
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Vital Signs Chart
                      SignalChartWidget(
                        isActive: _isMonitoring,
                        title: "Vital Signs",
                        channelNames: const [
                          "Heart Rate",
                          "Breathing Rate",
                          "Body Temperature",
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sleep Stage Analysis
                      Container(
                        width: double.infinity,
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
                            Row(
                              children: [
                                Icon(
                                  Iconsax.activity,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Sleep Stage Analysis",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isMonitoring) ...[
                              _buildSleepStageIndicator("Awake", false),
                              _buildSleepStageIndicator("Light Sleep", true),
                              _buildSleepStageIndicator("Deep Sleep", false),
                              _buildSleepStageIndicator("REM Sleep", false),
                            ] else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    "Start monitoring to see sleep stage analysis",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildSleepStageIndicator(String stage, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blue : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            stage,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Current",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
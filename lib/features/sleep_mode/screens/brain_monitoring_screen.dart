import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:path_provider/path_provider.dart';
import '../../../ui/components/gradient_background.dart';
import '../widgets/real_signal_chart_widget.dart';
import '../widgets/spectrum_chart_widget.dart';

class BrainMonitoringScreen extends StatefulWidget {
  final BrainBit? sensor;
  const BrainMonitoringScreen({super.key, this.sensor});

  @override
  State<BrainMonitoringScreen> createState() => _BrainMonitoringScreenState();
}

class _BrainMonitoringScreenState extends State<BrainMonitoringScreen> {
  bool _isMonitoring = false;
  String _sessionStatus = "Ready to start";
  DateTime? _sessionStartTime;

  File? _sessionFile;
  IOSink? _fileSink;
  StreamSubscription? _signalSub;

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
      await _stopMonitoring();
    } else {
      await _startMonitoring();
    }
  }

  /// 🟢 Start EEG monitoring session
  Future<void> _startMonitoring() async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
    final filePath = "${dir.path}/EEG_Session_$timestamp.csv";

    print("💾 EEG data will be saved to: $filePath");

    _sessionFile = File(filePath);
    await _sessionFile!.writeAsString("timestamp,O1,O2,T3,T4\n");
    _fileSink = _sessionFile!.openWrite(mode: FileMode.append);

    if (widget.sensor != null) {
      // 🧠 Real BrainBit Mode
      _signalSub = widget.sensor!.signalDataStream.listen(_onEEGData);
      await widget.sensor!.execute(FSensorCommand.startSignal);
      debugPrint("✅ Real BrainBit monitoring started");
    } else {
      // 🧪 Fallback demo mode
      _signalSub = Stream.periodic(
        const Duration(milliseconds: 100),
      ).listen((_) => _simulateEEGData());
      debugPrint("⚙️ Demo mode active (simulated EEG)");
    }

    setState(() {
      _isMonitoring = true;
      _sessionStartTime = DateTime.now();
      _sessionStatus =
          widget.sensor != null
              ? "Monitoring active (Real)"
              : "Demo mode active";
    });
  }

  /// 🔴 Stop monitoring and close file
  Future<void> _stopMonitoring() async {
    if (!_isMonitoring) return;
    try {
      await widget.sensor?.execute(FSensorCommand.stopSignal);
    } catch (_) {}

    await _signalSub?.cancel();
    _signalSub = null;

    await _fileSink?.flush();
    await _fileSink?.close();

    setState(() {
      _isMonitoring = false;
      _sessionStartTime = null;
      _sessionStatus = "Monitoring stopped";
    });

    debugPrint("🛑 EEG session stopped and file closed.");
  }

  /// 💾 Handle real EEG samples
  void _onEEGData(List<BrainBitSignalData> event) {
    final buffer = StringBuffer();
    for (var sample in event) {
      final ts = DateTime.now().toIso8601String();
      final o1 = (sample.o1 * 1e6).toStringAsFixed(3);
      final o2 = (sample.o2 * 1e6).toStringAsFixed(3);
      final t3 = (sample.t3 * 1e6).toStringAsFixed(3);
      final t4 = (sample.t4 * 1e6).toStringAsFixed(3);
      buffer.writeln("$ts,$o1,$o2,$t3,$t4");
    }
    _fileSink?.write(buffer.toString());
  }

  /// 🧪 Demo EEG signal generator (for testing)
  void _simulateEEGData() {
    final ts = DateTime.now().toIso8601String();
    final random = Random();
    final value =
        sin(DateTime.now().millisecond / 100) * 50 + random.nextDouble() * 5;
    final o1 = (value + random.nextDouble() * 2).toStringAsFixed(3);
    final o2 = (value + random.nextDouble() * 2).toStringAsFixed(3);
    final t3 = (value + random.nextDouble() * 2).toStringAsFixed(3);
    final t4 = (value + random.nextDouble() * 2).toStringAsFixed(3);
    _fileSink?.writeln("$ts,$o1,$o2,$t3,$t4");
  }

  String _getSessionDuration() {
    if (_sessionStartTime == null) return "00:00:00";
    final d = DateTime.now().difference(_sessionStartTime!);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
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
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              _buildStatusCard(textTheme),
              const SizedBox(height: 20),
              _buildControlButton(colorScheme),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RealSignalChartWidget(
                        sensor: widget.sensor,
                        isActive: _isMonitoring,
                        title: "EEG Brain Signals",
                        channelNames: const [
                          "O1 (Occipital Left)",
                          "O2 (Occipital Right)",
                          "T3 (Temporal Left)",
                          "T4 (Temporal Right)",
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (widget.sensor != null)
                        SpectrumChart(sensor: widget.sensor!),
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

  Widget _buildStatusCard(TextTheme textTheme) {
    return Container(
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
          if (_isMonitoring)
            Column(
              children: [
                Text(
                  "Session Duration",
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder:
                      (context, _) => Text(
                        _getSessionDuration(),
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              _isMonitoring ? Colors.red.shade600 : colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _toggleMonitoring,
        icon: Icon(_isMonitoring ? Iconsax.stop : Iconsax.play, size: 20),
        label: Text(
          _isMonitoring ? "Stop & Save" : "Start Monitoring",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/scheduler.dart';

class SleepSessionView extends StatefulWidget {
  const SleepSessionView({super.key});

  @override
  State<SleepSessionView> createState() => _SleepSessionViewState();
}

class _SleepSessionViewState extends State<SleepSessionView> {
  Duration elapsed = Duration.zero;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration duration) {
    setState(() {
      elapsed = _stopwatch.elapsed;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Sleep icon placeholder
            Icon(Iconsax.moon5, size: 72, color: colorScheme.primary),

            const SizedBox(height: 8),
            Text("Alarm active in 7h30 min"),

            const SizedBox(height: 16),
            Text(
              "Have a nice dream!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Description text about something on this page that can be long or short.",
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What is going on",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _timelineItem(
                    "22:15",
                    "Sleep initiated",
                    "EEG shows alpha-to-theta transition.",
                  ),
                  _timelineItem(
                    "23:15",
                    "Room too warm (28°C)",
                    "Fan auto turned on via IoT integration.",
                  ),
                  _timelineItem(
                    "01:45",
                    "Entered Deep Sleep",
                    "Dominant delta waves detected.",
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Timer display
            Text(
              _formatDuration(elapsed),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Quit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Text("Quit", style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(String time, String title, String desc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.record_circle5, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$time — $title",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

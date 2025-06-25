import 'package:ease_sleep_optimization/features/sleepMode/screens/sleepSessionView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});

  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen> {
  bool isAlarmOn = true;
  bool isSnoozeOn = false;
  final List<String> alarmPresets = [
    'Workday Wake: 07:00AM',
    'Weekend Chill: 09:00AM',
    'Custom',
  ];
  String selectedPreset = 'Workday Wake: 07:00AM';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surfaceVariant,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Text(
              "It’s time for sleep",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Check your sleep settings and start your sleep session.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            /// Alarm Settings Card
            _buildCard(
              title: "Alarm Settings",
              trailing: TextButton(
                onPressed: () {},
                child: Text(
                  "Edit >",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: selectedPreset,
                    isExpanded: true,
                    items:
                        alarmPresets.map((preset) {
                          return DropdownMenuItem<String>(
                            value: preset,
                            child: Text(
                              preset,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPreset = value);
                      }
                    },
                  ),
                  const SizedBox(height: 4),

                  const SizedBox(height: 4),
                  const Text(
                    "Alarm active in 7h30 min",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("Alarm Status"),
                    value: isAlarmOn,
                    onChanged: (value) {
                      setState(() => isAlarmOn = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Snooze"),
                    value: isSnoozeOn,
                    onChanged: (value) {
                      setState(() => isSnoozeOn = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// Pre-sleep Activities
            _buildCard(
              title: "Pre-sleep Activities",
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  _activityIcon(Icons.no_drinks, "Alcohol", theme),
                  _activityIcon(Icons.coffee, "Caffeine", theme),
                  _activityIcon(Icons.fitness_center, "Workout", theme),
                  _activityIcon(Icons.menu_book, "Read", theme),
                  _activityIcon(Icons.self_improvement, "Meditation", theme),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// Connected Devices
            _buildCard(
              title: "Connected Devices",
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _deviceButton(Icons.light_mode, "Lights", theme),
                  _deviceButton(Icons.spa, "Scent Diffuser", theme),
                  _deviceButton(Icons.ac_unit, "Air Conditioner", theme),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SleepSessionView()),
                );
              },
              child: Text(
                "Start Sleep Session",
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text("Cancel", style: textTheme.labelLarge),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _activityIcon(IconData icon, String label, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _deviceButton(IconData icon, String label, ThemeData theme) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 16, color: theme.colorScheme.onSurface),
      label: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}

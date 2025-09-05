import 'package:ease_sleep_optimization/core/constants/app_spacings.dart';
import 'package:ease_sleep_optimization/features/sleepMode/screens/sleepSessionView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/components/gradient_background.dart';
import '../../../core/models/alarm.dart';
import '../../control/providers/alarm_provider.dart';
import '../../control/screens/alarm_list_screen.dart';

class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});

  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen> {
  String? selectedAlarmId;
  
  @override
  void initState() {
    super.initState();
    // Initialize default alarms if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmsProvider.notifier).initializeDefaultAlarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Text(
                "It’s time for sleep",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              Text(
                "Check your sleep settings and start your sleep session.",
                textAlign: TextAlign.left,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              /// Alarm Settings Card
              _buildCard(
                title: "Alarm Settings",
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AlarmListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Edit >",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final alarms = ref.watch(alarmsProvider);
                    final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();
                    final selectedAlarm = selectedAlarmId != null 
                        ? alarms.firstWhere(
                            (alarm) => alarm.id == selectedAlarmId,
                            orElse: () => activeAlarms.isNotEmpty ? activeAlarms.first : alarms.first,
                          )
                        : (activeAlarms.isNotEmpty ? activeAlarms.first : alarms.first);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (alarms.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: selectedAlarmId ?? selectedAlarm.id,
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF1E1E1E),
                              items: alarms.map((alarm) {
                                return DropdownMenuItem<String>(
                                  value: alarm.id,
                                  child: Text(
                                    "${alarm.label} (${alarm.time})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedAlarmId = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getAlarmTimeUntilText(selectedAlarm),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text(
                              "Alarm Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedAlarm.isActive,
                            activeColor: colorScheme.primary,
                            onChanged: (value) {
                              ref.read(alarmsProvider.notifier).toggleAlarmStatus(selectedAlarm.id);
                            },
                          ),
                          SwitchListTile(
                            title: const Text(
                              "Snooze",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedAlarm.snoozeEnabled,
                            activeColor: colorScheme.primary,
                            onChanged: (value) {
                              final updatedAlarm = Alarm(
                                id: selectedAlarm.id,
                                time: selectedAlarm.time,
                                label: selectedAlarm.label,
                                sound: selectedAlarm.sound,
                                snoozeEnabled: value,
                                snoozeDuration: selectedAlarm.snoozeDuration,
                                alarmType: selectedAlarm.alarmType,
                                repeatDays: selectedAlarm.repeatDays,
                                createdAt: selectedAlarm.createdAt,
                                updatedAt: DateTime.now(),
                                isActive: selectedAlarm.isActive,
                              );
                              ref.read(alarmsProvider.notifier).updateAlarm(updatedAlarm);
                            },
                          ),
                        ] else ...[
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "No alarms set",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AlarmListScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Add Alarm",
                                    style: TextStyle(color: colorScheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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
                    _activityIcon(Iconsax.danger5, "Alcohol", theme),
                    _activityIcon(Iconsax.coffee5, "Caffeine", theme),
                    _activityIcon(Iconsax.heart5, "Workout", theme),
                    _activityIcon(Iconsax.book5, "Read", theme),
                    _activityIcon(Iconsax.cloud5, "Meditation", theme),
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
                    _deviceButton(Iconsax.lamp5, "Lights", theme),
                    _deviceButton(Iconsax.lovely5, "Scent Diffuser", theme),
                    _deviceButton(Iconsax.wind_25, "Air Conditioner", theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// Buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SleepSessionView()),
                  );
                },
                child: const Text(
                  "Start Sleep Session",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              const SizedBox(height: AppSpacing.xLarge),
            ],
          ),
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
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
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
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _deviceButton(IconData icon, String label, ThemeData theme) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        foregroundColor: Colors.white,
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _getAlarmTimeUntilText(Alarm alarm) {
    if (!alarm.isActive) {
      return "Alarm is inactive";
    }

    final now = DateTime.now();
    final timeParts = alarm.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Create alarm time for today
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If alarm time has passed today, set for tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    // Check if alarm should repeat on specific days
    if (alarm.repeatDays.isNotEmpty) {
      // Find the next valid day for this alarm
      var checkDate = alarmTime;
      while (!alarm.repeatDays.contains(checkDate.weekday % 7)) {
        checkDate = checkDate.add(const Duration(days: 1));
      }
      alarmTime = checkDate;
    }

    final difference = alarmTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return "Alarm active in ${hours}h ${minutes}min";
    } else {
      return "Alarm active in ${minutes}min";
    }
  }
}

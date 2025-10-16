import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/alarm.dart';
import '../../../ui/components/gradient_background.dart';
import '../providers/alarm_provider.dart';
import 'add_edit_alarm_screen.dart';
import 'alarm_ringing_screen.dart';
import '../../../core/services/alarm_service.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
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
    final alarms = ref.watch(alarmsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Alarm Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.alarm5, color: Colors.white),
            onPressed: () => _testAlarm(),
          ),
          IconButton(
            icon: const Icon(Iconsax.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAlarmScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: alarms.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return _buildAlarmCard(alarm);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.clock5,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms set',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first alarm',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(Alarm alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRepeatDays(alarm.repeatDays),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: alarm.isActive,
                    onChanged: (value) {
                      ref.read(alarmsProvider.notifier).toggleAlarmStatus(alarm.id);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Iconsax.more,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    color: const Color(0xFF2E2E2E),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Iconsax.edit_2, color: Colors.white70, size: 18),
                            SizedBox(width: 12),
                            Text('Edit', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, color: Colors.redAccent, size: 18),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditAlarmScreen(alarm: alarm),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(alarm);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          if (alarm.snoozeEnabled) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.timer5,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Snooze: ${alarm.snoozeDuration} min',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Iconsax.music5,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  alarm.sound,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatDays(List<int> repeatDays) {
    if (repeatDays.isEmpty) {
      return Text(
        'One time',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      );
    }

    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Row(
      children: List.generate(7, (index) {
        final isActive = repeatDays.contains(index);
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
            border: Border.all(
              color: isActive 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              dayNames[index],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmation(Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text(
          'Delete Alarm',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${alarm.label}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(alarmsProvider.notifier).deleteAlarm(alarm.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  /// Test alarm functionality with immediate alarm
  void _testAlarm() async {
    // Create a test alarm for immediate testing
    final testAlarm = Alarm(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      time: '${DateTime.now().hour.toString().padLeft(2, '0')}:${(DateTime.now().minute + 1).toString().padLeft(2, '0')}',
      label: 'Test Alarm',
      sound: 'Gentle Rise',
      snoozeEnabled: true,
      snoozeDuration: 1, // 1 minute for testing
      alarmType: 'test',
      isActive: true,
      repeatDays: [],
      createdAt: DateTime.now(),
    );

    try {
      await AlarmService.addAlarm(testAlarm);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test alarm set for 1 minute from now!'),
            backgroundColor: Colors.green,
          ),
        );

        // Show alarm ringing screen immediately for UI testing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlarmRingingScreen(
              alarmId: testAlarm.id,
              title: testAlarm.label,
              time: testAlarm.time,
            ),
          ),
        );

        // Also trigger an immediate alarm for testing real functionality
        await AlarmService.showImmediateTestAlarm(testAlarm.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set test alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
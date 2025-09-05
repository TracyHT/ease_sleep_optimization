import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_spacings.dart';
import '../providers/controls_provider.dart';
import '../../../ui/components/gradient_background.dart';
import 'alarm_settings_screen.dart';

class ControlsScreen extends ConsumerWidget {
  const ControlsScreen({super.key});

  void _navigateToAlarmSettings(
    BuildContext context,
    String alarmType,
    String initialValue,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AlarmSettingsScreen(
              alarmType: alarmType,
              initialValue: initialValue,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controls = ref.watch(controlsProvider);

    return Scaffold(
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenEdgePadding.left,
              MediaQuery.of(context).padding.top,
              AppSpacing.screenEdgePadding.right,
              AppSpacing.screenEdgePadding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Smart Sleep Controls',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage devices, alarms, and optimize your sleep environment.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Iconsax.setting_2,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controls['devicesConnected']} devices connected',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // Smart Alarm Section
                _SectionCard(
                  title: 'Smart Alarms',
                  children: [
                    _AlarmField(
                      label: 'Workday Wake',
                      value: controls['workdayWake'],
                      onTap:
                          () => _navigateToAlarmSettings(
                            context,
                            'Workday Wake',
                            controls['workdayWake'],
                          ),
                    ),
                    _AlarmField(
                      label: 'Weekend Chill',
                      value: controls['weekendChill'],
                      onTap:
                          () => _navigateToAlarmSettings(
                            context,
                            'Weekend Chill',
                            controls['weekendChill'],
                          ),
                    ),
                    _AlarmField(
                      label: 'Powerful Nap',
                      value: controls['powerfulNap'],
                      onTap:
                          () => _navigateToAlarmSettings(
                            context,
                            'Powerful Nap',
                            controls['powerfulNap'],
                          ),
                    ),
                  ],
                ),

                // Environment Section
                _SectionCard(
                  title: 'Current Environment',
                  children: [
                    _EnvironmentRow(
                      label: 'Temperature',
                      value: controls['environment']['temperature'],
                    ),
                    _EnvironmentRow(
                      label: 'Humidity',
                      value: controls['environment']['humidity'],
                    ),
                    _EnvironmentRow(
                      label: 'Light',
                      value: controls['environment']['light'],
                    ),
                    _EnvironmentRow(
                      label: 'Noise',
                      value: controls['environment']['noise'],
                    ),
                  ],
                ),

                // Connected Devices Section
                _SectionCard(
                  title: 'Connected Devices',
                  children:
                      controls['connectedDevices']
                          .map<Widget>(
                            (device) => _DeviceRow(
                              name: device['name'],
                              status: device['status'],
                              icon:
                                  Iconsax
                                      .cpu_charge, // Replace with logic if needed
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Section container card
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.large),
      color: theme.colorScheme.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Alarm field row
class _AlarmField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AlarmField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(value, style: theme.textTheme.bodySmall),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Environment data row
class _EnvironmentRow extends StatelessWidget {
  final String label;
  final String value;

  const _EnvironmentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// Device row
class _DeviceRow extends StatelessWidget {
  final String name;
  final String status;
  final IconData icon;

  const _DeviceRow({
    required this.name,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          Text(
            status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

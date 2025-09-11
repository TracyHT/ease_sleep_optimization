import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_spacings.dart';
import '../providers/controls_provider.dart';
import '../../../ui/components/gradient_background.dart';
import '../../sleepMode/screens/brain_monitoring_screen.dart';

class ControlsScreen extends ConsumerWidget {
  const ControlsScreen({super.key});

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
                  'Device & Environment Control',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect your BrainBit EEG headband and IoT devices for optimal sleep monitoring.',
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
                      '${_getConnectedDevicesCount(controls)} devices connected',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // EEG Device Section
                _SectionCard(
                  title: 'EEG Monitoring',
                  children: [
                    _DeviceConnectionCard(
                      deviceName: 'BrainBit EEG Headband',
                      deviceType: 'EEG Monitor',
                      connectionStatus:
                          controls['brainbitStatus'] ?? 'Disconnected',
                      icon: Iconsax.activity,
                      onConnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .connectBrainBit(),
                      onDisconnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .disconnectBrainBit(),
                      onViewSignals: (controls['brainbitStatus'] ?? 'Disconnected').toLowerCase() == 'connected'
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BrainMonitoringScreen(),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),

                // IoT Devices Section
                _SectionCard(
                  title: 'Smart Environment Devices',
                  children: [
                    _DeviceConnectionCard(
                      deviceName: 'Smart Thermostat',
                      deviceType: 'Temperature Control',
                      connectionStatus:
                          controls['thermostatStatus'] ?? 'Disconnected',
                      icon: Iconsax.cpu_charge,
                      onConnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .connectThermostat(),
                      onDisconnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .disconnectThermostat(),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    _DeviceConnectionCard(
                      deviceName: 'Smart Light Controller',
                      deviceType: 'Lighting Control',
                      connectionStatus:
                          controls['lightStatus'] ?? 'Disconnected',
                      icon: Iconsax.lamp,
                      onConnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .connectSmartLight(),
                      onDisconnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .disconnectSmartLight(),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    _DeviceConnectionCard(
                      deviceName: 'Air Quality Monitor',
                      deviceType: 'Humidity & Air Control',
                      connectionStatus:
                          controls['airQualityStatus'] ?? 'Disconnected',
                      icon: Iconsax.wind_2,
                      onConnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .connectAirQuality(),
                      onDisconnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .disconnectAirQuality(),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    _DeviceConnectionCard(
                      deviceName: 'Sound Controller',
                      deviceType: 'Noise Management',
                      connectionStatus:
                          controls['soundStatus'] ?? 'Disconnected',
                      icon: Iconsax.volume_high,
                      onConnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .connectSoundController(),
                      onDisconnect:
                          () =>
                              ref
                                  .read(controlsProvider.notifier)
                                  .disconnectSoundController(),
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

                // Device Status Summary
                _SectionCard(
                  title: 'Connected Devices Summary',
                  children: [
                    _buildDeviceStatusRow(
                      context,
                      'EEG Monitoring',
                      controls['brainbitStatus'] ?? 'Disconnected',
                      Iconsax.activity,
                    ),
                    _buildDeviceStatusRow(
                      context,
                      'Temperature Control',
                      controls['thermostatStatus'] ?? 'Disconnected',
                      Iconsax.cpu_charge,
                    ),
                    _buildDeviceStatusRow(
                      context,
                      'Lighting Control',
                      controls['lightStatus'] ?? 'Disconnected',
                      Iconsax.lamp,
                    ),
                    _buildDeviceStatusRow(
                      context,
                      'Air Quality',
                      controls['airQualityStatus'] ?? 'Disconnected',
                      Iconsax.wind_2,
                    ),
                    _buildDeviceStatusRow(
                      context,
                      'Sound Control',
                      controls['soundStatus'] ?? 'Disconnected',
                      Iconsax.volume_high,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to count connected devices
  int _getConnectedDevicesCount(Map<String, dynamic> controls) {
    int count = 0;
    final deviceStatuses = [
      controls['brainbitStatus'],
      controls['thermostatStatus'],
      controls['lightStatus'],
      controls['airQualityStatus'],
      controls['soundStatus'],
    ];

    for (final status in deviceStatuses) {
      if (status?.toString().toLowerCase() == 'connected') {
        count++;
      }
    }
    return count;
  }

  // Helper method to build device status rows
  Widget _buildDeviceStatusRow(
    BuildContext context,
    String deviceType,
    String status,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isConnected = status.toLowerCase() == 'connected';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: (isConnected ? Colors.green : Colors.grey)
                .withValues(alpha: 0.1),
            child: Icon(
              icon,
              size: 16,
              color: isConnected ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(child: Text(deviceType, style: theme.textTheme.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isConnected ? Colors.green : Colors.grey).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isConnected ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Device Connection Card Widget
class _DeviceConnectionCard extends StatelessWidget {
  final String deviceName;
  final String deviceType;
  final String connectionStatus;
  final IconData icon;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onViewSignals;

  const _DeviceConnectionCard({
    required this.deviceName,
    required this.deviceType,
    required this.connectionStatus,
    required this.icon,
    required this.onConnect,
    required this.onDisconnect,
    this.onViewSignals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = connectionStatus.toLowerCase() == 'connected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isConnected
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: (isConnected
                        ? Colors.green
                        : theme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  size: 20,
                  color: isConnected ? Colors.green : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deviceName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deviceType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConnected ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  connectionStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isConnected ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          if (!isConnected)
            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConnect,
                icon: const Icon(Iconsax.link, size: 16),
                label: const Text(
                  'Connect Device',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.5,
                  ),
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else
            // Connected - Show buttons
            Column(
              children: [
                // View Signals button (for BrainBit only)
                if (onViewSignals != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewSignals,
                      icon: const Icon(Iconsax.chart, size: 16),
                      label: const Text(
                        'View Live Signals',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Disconnect and Settings row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _showDisconnectDialog(
                              context,
                              deviceName,
                              onDisconnect,
                            ),
                        icon: const Icon(Iconsax.close_circle, size: 16),
                        label: const Text(
                          'Disconnect',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeviceSettings(context, deviceName),
                        icon: const Icon(Iconsax.setting_2, size: 16),
                        label: const Text(
                          'Settings',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary.withValues(
                            alpha: 0.2,
                          ),
                          foregroundColor: theme.colorScheme.secondary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Show disconnect confirmation dialog
  void _showDisconnectDialog(
    BuildContext context,
    String deviceName,
    VoidCallback onDisconnect,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2E2E2E),
            title: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Disconnect Device',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to disconnect $deviceName? This will stop monitoring and control features for this device.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDisconnect();
                },
                child: const Text(
                  'Disconnect',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Show device settings dialog
  void _showDeviceSettings(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2E2E2E),
            title: Row(
              children: [
                const Icon(Iconsax.setting_2, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$deviceName Settings',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Iconsax.cpu_charge,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Device Information',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Show device info
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Iconsax.notification,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Configure notifications
                  },
                ),
                ListTile(
                  leading: const Icon(Iconsax.refresh, color: Colors.white70),
                  title: const Text(
                    'Calibrate Device',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Start calibration
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
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
          mainAxisSize: MainAxisSize.min,
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

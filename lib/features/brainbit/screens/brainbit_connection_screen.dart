/**
 * BrainBit Connection Screen
 * 
 * The main screen for discovering and connecting to BrainBit EEG devices.
 * This screen provides a user-friendly interface for device management,
 * including scanning, permission handling, and connection status display.
 * 
 * Features:
 * - Device discovery and scanning
 * - Permission management
 * - Connection status display
 * - Error handling with user feedback
 * - Navigation to signal monitoring
 * - Clean, medical-grade UI design
 * 
 * Architecture:
 * - Uses Riverpod for state management
 * - Delegates to service layer for business logic
 * - Responsive design for different screen sizes
 * 
 * Usage:
 * - Navigate from Controls screen
 * - Handles complete BrainBit connection workflow
 * - Provides feedback for all user actions
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/components/gradient_background.dart';
import '../providers/brainbit_provider.dart';
import '../widgets/device_card_widget.dart';
import '../../sleepMode/screens/brain_monitoring_screen.dart';

/// Main screen for BrainBit device connection management
class BrainBitConnectionScreen extends ConsumerStatefulWidget {
  const BrainBitConnectionScreen({super.key});

  @override
  ConsumerState<BrainBitConnectionScreen> createState() => _BrainBitConnectionScreenState();
}

class _BrainBitConnectionScreenState extends ConsumerState<BrainBitConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final brainbitState = ref.watch(brainbitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BrainBit Connection",
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
              // Connection Status Card
              _buildStatusCard(context, brainbitState),
              
              const SizedBox(height: 20),

              // Action Buttons Section
              _buildActionButtons(context, brainbitState),
              
              const SizedBox(height: 24),

              // Device List Section
              _buildDeviceListSection(context, brainbitState),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main status display card
  Widget _buildStatusCard(BuildContext context, BrainBitState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
          // Status Icon
          Icon(
            _getStatusIcon(state),
            size: 48,
            color: _getStatusIconColor(state, colorScheme),
          ),
          
          const SizedBox(height: 12),
          
          // Status Title
          Text(
            _getStatusTitle(state),
            style: textTheme.titleMedium?.copyWith(
              color: _getStatusIconColor(state, colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Status Message
          Text(
            state.statusMessage,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),

          // Error Message (if any)
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(brainbitProvider.notifier).clearError(),
                    icon: const Icon(Iconsax.close_circle, color: Colors.red, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the action buttons section
  Widget _buildActionButtons(BuildContext context, BrainBitState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.hasConnectedDevice) {
      // Connected device - show monitoring and disconnect buttons
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _navigateToMonitoring(context),
              icon: const Icon(Iconsax.chart, size: 20),
              label: const Text(
                "View Live Signals",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => ref.read(brainbitProvider.notifier).disconnect(),
              icon: const Icon(Iconsax.close_circle, size: 20),
              label: const Text(
                "Disconnect Device",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // No device connected - show scan button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: state.isScanning ? Colors.orange : colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: state.isBusy ? null : _handleScanButton,
          icon: state.isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Iconsax.search_normal, size: 20),
          label: Text(
            state.isScanning ? "Searching..." : "Search for BrainBit Devices",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  /// Builds the device list section
  Widget _buildDeviceListSection(BuildContext context, BrainBitState state) {
    final textTheme = Theme.of(context).textTheme;

    if (state.discoveredDevices.isNotEmpty) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Discovered Devices",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = state.discoveredDevices[index];
                  return DeviceCardWidget(
                    device: device,
                    isConnecting: state.isConnecting && state.connectedDevice?.id == device.id,
                    onConnect: () => ref.read(brainbitProvider.notifier).connectToDevice(device),
                    onDisconnect: () => ref.read(brainbitProvider.notifier).disconnect(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (state.isScanning) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Searching for BrainBit devices...",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Make sure your BrainBit is ON and in pairing mode",
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.search_normal,
                size: 64,
                color: Colors.white30,
              ),
              const SizedBox(height: 16),
              Text(
                "No devices found yet",
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tap search to find nearby BrainBit devices",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Handles scan button press
  void _handleScanButton() {
    final notifier = ref.read(brainbitProvider.notifier);
    if (ref.read(brainbitProvider).isScanning) {
      notifier.stopScanning();
    } else {
      notifier.startScanning();
    }
  }

  /// Navigates to brain monitoring screen
  void _navigateToMonitoring(BuildContext context) {
    final connectedSensor = ref.read(brainbitProvider.notifier).connectedSensor;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrainMonitoringScreen(sensor: connectedSensor),
      ),
    );
  }

  /// Gets appropriate status icon
  IconData _getStatusIcon(BrainBitState state) {
    if (state.hasConnectedDevice) return Iconsax.tick_circle;
    if (state.isScanning) return Iconsax.radar_1;
    if (state.errorMessage != null) return Iconsax.warning_2;
    return Iconsax.activity;
  }

  /// Gets status icon color
  Color _getStatusIconColor(BrainBitState state, ColorScheme colorScheme) {
    if (state.hasConnectedDevice) return Colors.green;
    if (state.isScanning) return Colors.orange;
    if (state.errorMessage != null) return Colors.red;
    return colorScheme.primary;
  }

  /// Gets status title text
  String _getStatusTitle(BrainBitState state) {
    if (state.hasConnectedDevice) return "BrainBit Connected";
    if (state.isScanning) return "Scanning for Devices";
    if (state.errorMessage != null) return "Connection Error";
    return "BrainBit Disconnected";
  }
}
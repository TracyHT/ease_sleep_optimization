/**
 * Device Card Widget
 * 
 * A reusable widget for displaying BrainBit device information in a card format.
 * Shows device details, connection status, signal strength, and provides
 * action buttons for connecting/disconnecting devices.
 * 
 * Features:
 * - Device information display
 * - Connection status indicators
 * - Signal strength visualization
 * - Connect/disconnect actions
 * - Battery level display
 * - Responsive design
 * 
 * Usage:
 * - Used in device list screens
 * - Handles device connection actions
 * - Provides visual feedback for user interactions
 */

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/brainbit_device.dart';

/// Widget for displaying a BrainBit device in card format
class DeviceCardWidget extends StatelessWidget {
  /// The BrainBit device to display
  final BrainBitDevice device;
  
  /// Callback when connect button is pressed
  final VoidCallback? onConnect;
  
  /// Callback when disconnect button is pressed
  final VoidCallback? onDisconnect;
  
  /// Whether connection is currently in progress
  final bool isConnecting;

  const DeviceCardWidget({
    super.key,
    required this.device,
    this.onConnect,
    this.onDisconnect,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(colorScheme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Header Row
          Row(
            children: [
              // Device Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(colorScheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.activity,
                  color: _getIconColor(colorScheme),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.deviceTypeDisplayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Connection Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(colorScheme),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  device.connectionStatus.description,
                  style: TextStyle(
                    color: _getStatusTextColor(colorScheme),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Device Details Row
          Row(
            children: [
              // Serial Number
              _buildDetailItem(
                icon: Iconsax.code,
                label: 'Serial',
                value: device.id,
              ),
              
              const SizedBox(width: 16),
              
              // Signal Strength
              _buildDetailItem(
                icon: _getSignalStrengthIcon(),
                label: 'Signal',
                value: device.signalStrengthDescription,
              ),
              
              const Spacer(),
              
              // Battery Level (if available)
              if (device.batteryLevel != null)
                _buildBatteryIndicator(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  /// Builds the action buttons based on connection state
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    if (device.isConnected) {
      // Connected - show disconnect and view signals buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDisconnect,
              icon: const Icon(Iconsax.close_circle, size: 16),
              label: const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToSignals(context),
              icon: const Icon(Iconsax.chart, size: 16),
              label: const Text('View Signals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else {
      // Not connected - show connect button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isConnecting ? null : onConnect,
          icon: isConnecting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Iconsax.link, size: 16),
          label: Text(isConnecting ? 'Connecting...' : 'Connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }
  }

  /// Builds a detail item (icon + label + value)
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white60, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds battery level indicator
  Widget _buildBatteryIndicator() {
    final batteryLevel = device.batteryLevel!;
    final batteryColor = batteryLevel > 20 ? Colors.green : Colors.orange;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          batteryLevel > 50 ? Iconsax.battery_full : 
          batteryLevel > 20 ? Iconsax.battery_3full : Iconsax.battery_empty,
          color: batteryColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$batteryLevel%',
          style: TextStyle(
            color: batteryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Gets border color based on connection status
  Color _getBorderColor(ColorScheme colorScheme) {
    switch (device.connectionStatus) {
      case BrainBitConnectionStatus.connected:
        return Colors.green.withValues(alpha: 0.5);
      case BrainBitConnectionStatus.connecting:
        return Colors.orange.withValues(alpha: 0.5);
      case BrainBitConnectionStatus.failed:
      case BrainBitConnectionStatus.connectionLost:
        return Colors.red.withValues(alpha: 0.5);
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  /// Gets icon background color based on connection status
  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    switch (device.connectionStatus) {
      case BrainBitConnectionStatus.connected:
        return Colors.green.withValues(alpha: 0.2);
      case BrainBitConnectionStatus.connecting:
        return Colors.orange.withValues(alpha: 0.2);
      case BrainBitConnectionStatus.failed:
      case BrainBitConnectionStatus.connectionLost:
        return Colors.red.withValues(alpha: 0.2);
      default:
        return colorScheme.primary.withValues(alpha: 0.2);
    }
  }

  /// Gets icon color based on connection status
  Color _getIconColor(ColorScheme colorScheme) {
    switch (device.connectionStatus) {
      case BrainBitConnectionStatus.connected:
        return Colors.green;
      case BrainBitConnectionStatus.connecting:
        return Colors.orange;
      case BrainBitConnectionStatus.failed:
      case BrainBitConnectionStatus.connectionLost:
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  /// Gets status background color
  Color _getStatusBackgroundColor(ColorScheme colorScheme) {
    if (device.connectionStatus.isSuccessful) {
      return Colors.green.withValues(alpha: 0.2);
    } else if (device.connectionStatus.isError) {
      return Colors.red.withValues(alpha: 0.2);
    } else {
      return Colors.orange.withValues(alpha: 0.2);
    }
  }

  /// Gets status text color
  Color _getStatusTextColor(ColorScheme colorScheme) {
    if (device.connectionStatus.isSuccessful) {
      return Colors.green;
    } else if (device.connectionStatus.isError) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  /// Gets signal strength icon based on RSSI
  IconData _getSignalStrengthIcon() {
    if (device.rssi >= -50) return Iconsax.wifi5;
    if (device.rssi >= -70) return Iconsax.wifi5;
    return Iconsax.wifi5;
  }

  /// Navigates to signal monitoring screen
  void _navigateToSignals(BuildContext context) {
    Navigator.pushNamed(context, '/brain-monitoring');
  }
}
/**
 * BrainBit Device Model
 * 
 * This file contains data models for representing BrainBit EEG devices
 * in the sleep optimization app. It provides a clean abstraction over
 * the neurosdk2 FSensorInfo class with additional app-specific properties.
 * 
 * Features:
 * - Device information wrapper
 * - Connection status tracking
 * - Signal quality metrics
 * - Battery level monitoring
 * 
 * Usage:
 * - Used throughout the app to represent BrainBit devices
 * - Provides type safety and clear data structure
 * - Enables easy testing and mocking
 */

import 'package:neurosdk2/neurosdk2.dart';

/// Represents a BrainBit EEG device with connection and status information
class BrainBitDevice {
  /// Unique device identifier (serial number)
  final String id;
  
  /// Human-readable device name
  final String name;
  
  /// Bluetooth MAC address
  final String address;
  
  /// Device family (BrainBit2, BrainBitFlex, etc.)
  final FSensorFamily family;
  
  /// Bluetooth signal strength in dBm
  final int rssi;
  
  /// Whether device requires pairing
  final bool pairingRequired;
  
  /// Current connection status
  final BrainBitConnectionStatus connectionStatus;
  
  /// Battery level percentage (0-100, null if unknown)
  final int? batteryLevel;
  
  /// Signal quality (0.0-1.0, null if not connected)
  final double? signalQuality;
  
  /// Timestamp when device was discovered
  final DateTime discoveredAt;
  
  /// Raw neurosdk2 sensor info
  final FSensorInfo? sensorInfo;

  const BrainBitDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.family,
    required this.rssi,
    required this.pairingRequired,
    required this.connectionStatus,
    required this.discoveredAt,
    this.batteryLevel,
    this.signalQuality,
    this.sensorInfo,
  });

  /// Creates a BrainBitDevice from neurosdk2 FSensorInfo
  factory BrainBitDevice.fromFSensorInfo(FSensorInfo info) {
    return BrainBitDevice(
      id: info.serialNumber,
      name: info.name.isNotEmpty ? info.name : 'BrainBit Device',
      address: info.address,
      family: info.sensFamily,
      rssi: info.rssi,
      pairingRequired: info.pairingRequired,
      connectionStatus: BrainBitConnectionStatus.discovered,
      discoveredAt: DateTime.now(),
      sensorInfo: info,
    );
  }

  /// Creates a copy with updated properties
  BrainBitDevice copyWith({
    String? id,
    String? name,
    String? address,
    FSensorFamily? family,
    int? rssi,
    bool? pairingRequired,
    BrainBitConnectionStatus? connectionStatus,
    int? batteryLevel,
    double? signalQuality,
    DateTime? discoveredAt,
    FSensorInfo? sensorInfo,
  }) {
    return BrainBitDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      family: family ?? this.family,
      rssi: rssi ?? this.rssi,
      pairingRequired: pairingRequired ?? this.pairingRequired,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalQuality: signalQuality ?? this.signalQuality,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      sensorInfo: sensorInfo ?? this.sensorInfo,
    );
  }

  /// Returns device type display name
  String get deviceTypeDisplayName {
    switch (family) {
      case FSensorFamily.leBrainBit2:
        return 'BrainBit2';
      case FSensorFamily.leBrainBitFlex:
        return 'BrainBitFlex';
      default:
        return 'BrainBit';
    }
  }

  /// Returns signal strength description
  String get signalStrengthDescription {
    if (rssi >= -30) return 'Excellent';
    if (rssi >= -50) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Poor';
  }

  /// Whether device is currently connected
  bool get isConnected => connectionStatus == BrainBitConnectionStatus.connected;

  /// Whether device is in the process of connecting
  bool get isConnecting => connectionStatus == BrainBitConnectionStatus.connecting;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrainBitDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BrainBitDevice(id: $id, name: $name, status: $connectionStatus)';
}

/// Possible connection states for a BrainBit device
enum BrainBitConnectionStatus {
  /// Device has been discovered but not connected
  discovered,
  
  /// Device is in the process of connecting
  connecting,
  
  /// Device is successfully connected and ready for use
  connected,
  
  /// Device connection failed
  failed,
  
  /// Device has been disconnected
  disconnected,
  
  /// Device connection was lost unexpectedly
  connectionLost,
}

/// Extension to provide human-readable status descriptions
extension BrainBitConnectionStatusExtension on BrainBitConnectionStatus {
  /// Returns a user-friendly description of the connection status
  String get description {
    switch (this) {
      case BrainBitConnectionStatus.discovered:
        return 'Available';
      case BrainBitConnectionStatus.connecting:
        return 'Connecting...';
      case BrainBitConnectionStatus.connected:
        return 'Connected';
      case BrainBitConnectionStatus.failed:
        return 'Connection Failed';
      case BrainBitConnectionStatus.disconnected:
        return 'Disconnected';
      case BrainBitConnectionStatus.connectionLost:
        return 'Connection Lost';
    }
  }

  /// Returns whether the status represents a successful connection
  bool get isSuccessful => this == BrainBitConnectionStatus.connected;

  /// Returns whether the status represents an error state
  bool get isError => 
      this == BrainBitConnectionStatus.failed || 
      this == BrainBitConnectionStatus.connectionLost;
}
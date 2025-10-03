/**
 * BrainBit Provider
 * 
 * This provider manages the global state for BrainBit device functionality
 * in the sleep optimization app. It coordinates between scanning, connection,
 * and permission services while providing a clean state management interface.
 * 
 * Features:
 * - Centralized BrainBit state management
 * - Permission handling coordination
 * - Device scanning orchestration
 * - Connection state management
 * - Error handling and user feedback
 * - Memory leak prevention
 * 
 * Usage:
 * - Use with flutter_riverpod for state management
 * - Access via ref.watch(brainbitProvider) in widgets
 * - Call methods via ref.read(brainbitProvider.notifier)
 */

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurosdk2/neurosdk2.dart';
import '../models/brainbit_device.dart';
import '../services/brainbit_permission_service.dart';
import '../services/brainbit_scanner_service.dart';
import '../services/brainbit_connection_service.dart';

/// Global BrainBit provider instance
final brainbitProvider = StateNotifierProvider<BrainBitNotifier, BrainBitState>((ref) {
  return BrainBitNotifier();
});

/// State class for BrainBit functionality
class BrainBitState {
  /// List of discovered devices
  final List<BrainBitDevice> discoveredDevices;
  
  /// Currently connected device
  final BrainBitDevice? connectedDevice;
  
  /// Whether scanning is active
  final bool isScanning;
  
  /// Whether connection is in progress
  final bool isConnecting;
  
  /// Current status message
  final String statusMessage;
  
  /// Any error that occurred
  final String? errorMessage;
  
  /// Whether permissions are granted
  final bool permissionsGranted;

  const BrainBitState({
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.isScanning = false,
    this.isConnecting = false,
    this.statusMessage = 'Ready to search for BrainBit devices',
    this.errorMessage,
    this.permissionsGranted = false,
  });

  /// Creates a copy with updated properties
  BrainBitState copyWith({
    List<BrainBitDevice>? discoveredDevices,
    BrainBitDevice? connectedDevice,
    bool? isScanning,
    bool? isConnecting,
    String? statusMessage,
    String? errorMessage,
    bool? permissionsGranted,
    bool clearConnectedDevice = false,
    bool clearError = false,
  }) {
    return BrainBitState(
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
    );
  }

  /// Whether any device is connected
  bool get hasConnectedDevice => connectedDevice != null;

  /// Whether the system is busy (scanning or connecting)
  bool get isBusy => isScanning || isConnecting;

  @override
  String toString() => 'BrainBitState(devices: ${discoveredDevices.length}, connected: $hasConnectedDevice, scanning: $isScanning)';
}

/// State notifier for BrainBit functionality
class BrainBitNotifier extends StateNotifier<BrainBitState> {
  /// Scanner service instance
  final BrainBitScannerService _scannerService = BrainBitScannerService();
  
  /// Connection service instance
  final BrainBitConnectionService _connectionService = BrainBitConnectionService();
  
  /// Subscriptions for cleanup
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _scanningSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _deviceInfoSubscription;

  BrainBitNotifier() : super(const BrainBitState()) {
    _initializeServices();
  }

  /// Initializes service subscriptions
  void _initializeServices() {
    // Listen to device discovery updates
    _deviceSubscription = _scannerService.deviceStream.listen((devices) {
      state = state.copyWith(
        discoveredDevices: devices,
        statusMessage: devices.isEmpty 
            ? 'Scanning for BrainBit devices...'
            : 'Found ${devices.length} device(s)',
      );
    });

    // Listen to scanning state changes
    _scanningSubscription = _scannerService.scanningStream.listen((isScanning) {
      state = state.copyWith(
        isScanning: isScanning,
        statusMessage: isScanning 
            ? 'Scanning for BrainBit devices...'
            : (state.discoveredDevices.isEmpty 
                ? 'No devices found. Make sure your BrainBit is ON and in pairing mode.'
                : 'Found ${state.discoveredDevices.length} device(s). Tap Connect to pair.'),
      );
    });

    // Listen to connection state changes
    _connectionSubscription = _connectionService.connectionStateStream.listen((connectionState) {
      final device = state.connectedDevice;
      if (device != null) {
        final updatedDevice = device.copyWith(connectionStatus: connectionState);
        state = state.copyWith(
          connectedDevice: updatedDevice,
          isConnecting: connectionState == BrainBitConnectionStatus.connecting,
          statusMessage: _getConnectionStatusMessage(connectionState, device),
        );
        
        // Clear connected device if disconnected or failed
        if (connectionState == BrainBitConnectionStatus.disconnected ||
            connectionState == BrainBitConnectionStatus.failed) {
          state = state.copyWith(clearConnectedDevice: true);
        }
      }
    });

    // Listen to device info updates (battery level, etc.)
    _deviceInfoSubscription = _connectionService.deviceInfoStream.listen((deviceInfo) {
      final device = state.connectedDevice;
      if (device != null) {
        final updatedDevice = device.copyWith(batteryLevel: deviceInfo.batteryLevel);
        state = state.copyWith(connectedDevice: updatedDevice);
      }
    });
  }

  /// Checks permissions and starts device scanning
  Future<void> startScanning() async {
    try {
      state = state.copyWith(
        clearError: true,
        statusMessage: 'Checking permissions...',
      );

      // Check permissions first
      final permissionsGranted = await BrainBitPermissionService.checkAllPermissions();
      state = state.copyWith(permissionsGranted: permissionsGranted);

      if (!permissionsGranted) {
        state = state.copyWith(
          errorMessage: 'Permissions required. Please grant Bluetooth and Location permissions.',
          statusMessage: 'Permission check failed',
        );
        return;
      }

      // Start scanning
      await _scannerService.startScanning();
      
    } on BrainBitPermissionException catch (e) {
      state = state.copyWith(
        errorMessage: e.message,
        statusMessage: e.title,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        statusMessage: 'Failed to start scanning',
      );
    }
  }

  /// Stops device scanning
  Future<void> stopScanning() async {
    try {
      await _scannerService.stopScanning();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// Connects to a specific device
  Future<void> connectToDevice(BrainBitDevice device) async {
    if (device.sensorInfo == null) {
      state = state.copyWith(
        errorMessage: 'Invalid device information',
      );
      return;
    }

    try {
      state = state.copyWith(
        clearError: true,
        connectedDevice: device.copyWith(connectionStatus: BrainBitConnectionStatus.connecting),
        isConnecting: true,
        statusMessage: 'Connecting to ${device.name}...',
      );

      // Stop scanning while connecting
      await _scannerService.stopScanning();

      // Set scanner for connection service
      _connectionService.setScanner(_scannerService);

      // Connect to device
      await _connectionService.connectToDevice(device.sensorInfo!);

      state = state.copyWith(
        connectedDevice: device.copyWith(connectionStatus: BrainBitConnectionStatus.connected),
        isConnecting: false,
        statusMessage: 'Successfully connected to ${device.name}',
      );

    } catch (e) {
      state = state.copyWith(
        connectedDevice: device.copyWith(connectionStatus: BrainBitConnectionStatus.failed),
        isConnecting: false,
        errorMessage: e.toString(),
        statusMessage: 'Failed to connect to ${device.name}',
      );
    }
  }

  /// Disconnects from the current device
  Future<void> disconnect() async {
    try {
      await _connectionService.disconnect();
      
      state = state.copyWith(
        clearConnectedDevice: true,
        statusMessage: 'Device disconnected',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// Gets the connected sensor for signal streaming
  BrainBit? get connectedSensor => _connectionService.connectedSensor;

  /// Starts signal streaming from connected device
  Stream<List<BrainBitSignalData>>? startSignalStream() {
    try {
      return _connectionService.startSignalStream();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Stops signal streaming
  Future<void> stopSignalStream() async {
    try {
      await _connectionService.stopSignalStream();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// Clears any error messages
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Gets connection status message
  String _getConnectionStatusMessage(BrainBitConnectionStatus status, BrainBitDevice device) {
    switch (status) {
      case BrainBitConnectionStatus.connecting:
        return 'Connecting to ${device.name}...';
      case BrainBitConnectionStatus.connected:
        return 'Connected to ${device.name}';
      case BrainBitConnectionStatus.failed:
        return 'Failed to connect to ${device.name}';
      case BrainBitConnectionStatus.disconnected:
        return 'Disconnected from ${device.name}';
      case BrainBitConnectionStatus.connectionLost:
        return 'Connection lost with ${device.name}';
      default:
        return 'Ready';
    }
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    _scanningSubscription?.cancel();
    _deviceInfoSubscription?.cancel();
    _connectionSubscription?.cancel();
    
    _scannerService.dispose();
    _connectionService.dispose();
    
    super.dispose();
  }
}
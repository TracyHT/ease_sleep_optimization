/**
 * BrainBit Connection Service
 * 
 * This service handles the connection and configuration of BrainBit EEG devices.
 * It provides a clean abstraction over the neurosdk2 connection API with
 * proper error handling, device configuration, and connection state management.
 * 
 * Features:
 * - Device connection management
 * - Automatic amplifier configuration
 * - Connection state monitoring
 * - Signal stream management
 * - Battery and device info retrieval
 * - Proper cleanup and disposal
 * 
 * Usage:
 * - Call connectToDevice() with FSensorInfo
 * - Listen to connectionStateStream for status updates
 * - Access connectedSensor for signal streaming
 * - Call disconnect() when done
 */

import 'dart:async';
import 'package:neurosdk2/neurosdk2.dart';
import '../models/brainbit_device.dart';
import 'brainbit_scanner_service.dart';

/// Service for managing BrainBit device connections
class BrainBitConnectionService {
  /// Currently connected BrainBit2 sensor
  BrainBit2? _connectedSensor;
  
  /// Scanner service used for device creation
  BrainBitScannerService? _scannerService;
  
  /// Current connection state
  BrainBitConnectionStatus _connectionState = BrainBitConnectionStatus.disconnected;
  
  /// Stream controller for connection state updates
  final StreamController<BrainBitConnectionStatus> _connectionStateController = 
      StreamController<BrainBitConnectionStatus>.broadcast();
  
  /// Stream controller for device info updates
  final StreamController<BrainBitDeviceInfo> _deviceInfoController = 
      StreamController<BrainBitDeviceInfo>.broadcast();

  /// Current connected sensor (null if not connected)
  BrainBit2? get connectedSensor => _connectedSensor;
  
  /// Current connection state
  BrainBitConnectionStatus get connectionState => _connectionState;
  
  /// Stream of connection state changes
  Stream<BrainBitConnectionStatus> get connectionStateStream => 
      _connectionStateController.stream;
  
  /// Stream of device information updates
  Stream<BrainBitDeviceInfo> get deviceInfoStream => 
      _deviceInfoController.stream;
  
  /// Whether a device is currently connected
  bool get isConnected => _connectedSensor != null && 
      _connectionState == BrainBitConnectionStatus.connected;

  /// Sets the scanner service (required for device creation)
  void setScanner(BrainBitScannerService scannerService) {
    _scannerService = scannerService;
  }

  /// Connects to a BrainBit device
  /// 
  /// [deviceInfo] - The FSensorInfo from device discovery
  /// 
  /// Throws [BrainBitConnectionException] if connection fails
  Future<void> connectToDevice(FSensorInfo deviceInfo) async {
    if (_scannerService?.scanner == null) {
      throw const BrainBitConnectionException('Scanner not available. Start scanning first.');
    }
    
    if (_connectedSensor != null) {
      throw const BrainBitConnectionException('Another device is already connected');
    }

    _updateConnectionState(BrainBitConnectionStatus.connecting);

    try {
      // Create sensor from device info
      final sensor = await _scannerService!.scanner!.createSensor(deviceInfo);
      
      if (sensor is! BrainBit2) {
        throw const BrainBitConnectionException('Connected device is not BrainBit2');
      }
      
      _connectedSensor = sensor;
      
      // Configure the device
      await _configureDevice(sensor);
      
      // Get device information
      await _updateDeviceInfo(sensor);
      
      _updateConnectionState(BrainBitConnectionStatus.connected);
      
    } catch (e) {
      _connectedSensor?.dispose();
      _connectedSensor = null;
      _updateConnectionState(BrainBitConnectionStatus.failed);
      
      throw BrainBitConnectionException('Failed to connect: ${e.toString()}');
    }
  }

  /// Configures the BrainBit device with optimal settings
  Future<void> _configureDevice(BrainBit2 sensor) async {
    try {
      // Get channel count
      final channelCount = await sensor.channelsCount.value;
      
      // Configure amplifier parameters for optimal EEG recording
      final amplifierParams = BrainBit2AmplifierParam(
        chSignalMode: List.filled(channelCount, FBrainBit2ChannelMode.chModeNormal),
        chResistUse: List.filled(channelCount, true), // Enable resistance monitoring
        chGain: List.filled(channelCount, FSensorGain.gain3), // 3x gain for EEG
        current: FGenCurrent.genCurr6nA, // 6nA current for resistance check
      );
      
      await sensor.amplifierParam.set(amplifierParams);
      
    } catch (e) {
      throw BrainBitConnectionException('Failed to configure device: ${e.toString()}');
    }
  }

  /// Updates device information
  Future<void> _updateDeviceInfo(BrainBit2 sensor) async {
    try {
      final info = BrainBitDeviceInfo(
        serialNumber: await sensor.serialNumber.value,
        batteryLevel: await sensor.batteryPower.value,
        firmwareVersion: await sensor.version.value,
        channelCount: await sensor.channelsCount.value,
        samplingFrequency: await sensor.samplingFrequency.value,
        gain: await sensor.gain.value,
      );
      
      _deviceInfoController.add(info);
      
    } catch (e) {
      print('Warning: Failed to get device info: $e');
    }
  }

  /// Starts EEG signal streaming
  /// 
  /// Returns the signal data stream
  Stream<List<SignalChannelsData>>? startSignalStream() {
    if (_connectedSensor == null) {
      throw const BrainBitConnectionException('No device connected');
    }
    
    try {
      _connectedSensor!.execute(FSensorCommand.startSignal);
      return _connectedSensor!.signalDataStream;
    } catch (e) {
      throw BrainBitConnectionException('Failed to start signal stream: ${e.toString()}');
    }
  }

  /// Stops EEG signal streaming
  Future<void> stopSignalStream() async {
    if (_connectedSensor == null) return;
    
    try {
      _connectedSensor!.execute(FSensorCommand.stopSignal);
    } catch (e) {
      print('Warning: Failed to stop signal stream: $e');
    }
  }

  /// Starts resistance monitoring
  Stream<List<ResistRefChannelsData>>? startResistanceMonitoring() {
    if (_connectedSensor == null) {
      throw const BrainBitConnectionException('No device connected');
    }
    
    try {
      _connectedSensor!.execute(FSensorCommand.startResist);
      return _connectedSensor!.resistDataStream;
    } catch (e) {
      throw BrainBitConnectionException('Failed to start resistance monitoring: ${e.toString()}');
    }
  }

  /// Stops resistance monitoring
  Future<void> stopResistanceMonitoring() async {
    if (_connectedSensor == null) return;
    
    try {
      _connectedSensor!.execute(FSensorCommand.stopResist);
    } catch (e) {
      print('Warning: Failed to stop resistance monitoring: $e');
    }
  }

  /// Disconnects from the current device
  Future<void> disconnect() async {
    if (_connectedSensor == null) return;
    
    try {
      // Stop any active streams
      await stopSignalStream();
      await stopResistanceMonitoring();
      
      // Dispose of the sensor
      _connectedSensor!.dispose();
      
    } catch (e) {
      print('Warning: Error during disconnect: $e');
    } finally {
      _connectedSensor = null;
      _updateConnectionState(BrainBitConnectionStatus.disconnected);
    }
  }

  /// Updates connection state and notifies listeners
  void _updateConnectionState(BrainBitConnectionStatus newState) {
    _connectionState = newState;
    _connectionStateController.add(newState);
  }

  /// Gets current battery level
  Future<int?> getBatteryLevel() async {
    if (_connectedSensor == null) return null;
    
    try {
      return await _connectedSensor!.batteryPower.value;
    } catch (e) {
      print('Error getting battery level: $e');
      return null;
    }
  }

  /// Disposes resources and disconnects
  Future<void> dispose() async {
    await disconnect();
    
    await _connectionStateController.close();
    await _deviceInfoController.close();
  }
}

/// Information about a connected BrainBit device
class BrainBitDeviceInfo {
  final String serialNumber;
  final int batteryLevel;
  final FSensorVersion firmwareVersion;
  final int channelCount;
  final FSensorSamplingFrequency samplingFrequency;
  final FSensorGain gain;

  const BrainBitDeviceInfo({
    required this.serialNumber,
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.channelCount,
    required this.samplingFrequency,
    required this.gain,
  });

  /// Gets firmware version as readable string
  String get firmwareVersionString => 
      '${firmwareVersion.fwMajor}.${firmwareVersion.fwMinor}.${firmwareVersion.fwPatch}';

  /// Gets sampling frequency in Hz
  int get samplingFrequencyHz {
    switch (samplingFrequency) {
      case FSensorSamplingFrequency.hz125:
        return 125;
      case FSensorSamplingFrequency.hz250:
        return 250;
      case FSensorSamplingFrequency.hz500:
        return 500;
      case FSensorSamplingFrequency.hz1000:
        return 1000;
      default:
        return 250; // Default fallback
    }
  }
}

/// Custom exception for connection-related errors
class BrainBitConnectionException implements Exception {
  final String message;
  
  const BrainBitConnectionException(this.message);
  
  @override
  String toString() => 'BrainBitConnectionException: $message';
}
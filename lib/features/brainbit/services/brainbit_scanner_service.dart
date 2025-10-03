/**
 * BrainBit Scanner Service
 * 
 * This service handles device discovery and scanning functionality for BrainBit
 * EEG devices using the neurosdk2 library. It provides a clean abstraction
 * over the neurosdk2 Scanner API with proper error handling and state management.
 * 
 * Features:
 * - Automated BrainBit device discovery
 * - Real-time device list updates
 * - Scanning state management
 * - Error handling and recovery
 * - Memory leak prevention
 * 
 * Usage:
 * - Call startScanning() to begin device discovery
 * - Listen to deviceStream for real-time updates
 * - Call stopScanning() when done
 * - Always dispose() to prevent memory leaks
 */

import 'dart:async';
import 'package:neurosdk2/neurosdk2.dart';
import '../models/brainbit_device.dart';

/// Service for discovering and managing BrainBit devices
class BrainBitScannerService {
  /// Internal neurosdk2 scanner instance
  Scanner? _scanner;
  
  /// Timer for periodic device list updates
  Timer? _scanTimer;
  
  /// Stream controller for device updates
  final StreamController<List<BrainBitDevice>> _deviceController = 
      StreamController<List<BrainBitDevice>>.broadcast();
  
  /// Stream controller for scanning state updates
  final StreamController<bool> _scanningController = 
      StreamController<bool>.broadcast();
  
  /// Currently discovered devices
  final List<BrainBitDevice> _discoveredDevices = [];
  
  /// Whether scanning is currently active
  bool _isScanning = false;
  
  /// Maximum scan duration in seconds
  static const int maxScanDuration = 30;
  
  /// Device polling interval in milliseconds
  static const int pollingInterval = 500;

  /// Stream of discovered devices (updates in real-time)
  Stream<List<BrainBitDevice>> get deviceStream => _deviceController.stream;
  
  /// Stream of scanning state changes
  Stream<bool> get scanningStream => _scanningController.stream;
  
  /// Current list of discovered devices
  List<BrainBitDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  
  /// Whether scanner is currently active
  bool get isScanning => _isScanning;
  
  /// Gets the internal scanner (for device creation)
  Scanner? get scanner => _scanner;

  /// Starts scanning for BrainBit devices
  /// 
  /// Throws [BrainBitScannerException] if scanning fails to start
  Future<void> startScanning() async {
    if (_isScanning) {
      throw const BrainBitScannerException('Scanner is already running');
    }

    try {
      // Clear previous results
      _discoveredDevices.clear();
      _deviceController.add([]);
      
      // Create scanner for BrainBit devices
      _scanner = await Scanner.create([
        FSensorFamily.leBrainBit,
        FSensorFamily.leBrainBitBlack,
      ]);
      
      // Start the neurosdk2 scanner
      await _scanner!.start();
      
      _isScanning = true;
      _scanningController.add(true);
      
      // Start periodic device discovery polling
      _startDevicePolling();
      
      // Auto-stop after maximum duration
      Timer(const Duration(seconds: maxScanDuration), () {
        if (_isScanning) {
          stopScanning();
        }
      });
      
    } catch (e) {
      _isScanning = false;
      _scanningController.add(false);
      throw BrainBitScannerException('Failed to start scanning: ${e.toString()}');
    }
  }

  /// Stops scanning for devices
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      _scanTimer?.cancel();
      _scanTimer = null;
      
      await _scanner?.stop();
      
      _isScanning = false;
      _scanningController.add(false);
      
    } catch (e) {
      // Log error but don't throw - stopping should always succeed
      print('Warning: Error stopping scanner: $e');
    }
  }

  /// Starts periodic polling for discovered devices
  void _startDevicePolling() {
    _scanTimer = Timer.periodic(const Duration(milliseconds: pollingInterval), (timer) {
      if (!_isScanning || _scanner == null) {
        timer.cancel();
        return;
      }
      
      _updateDeviceList().catchError((e) => print('Error in device update: $e'));
    });
    
    // Also immediately check for devices
    _updateDeviceList().catchError((e) => print('Error in initial device update: $e'));
  }

  /// Updates the device list from scanner results
  Future<void> _updateDeviceList() async {
    try {
      if (_scanner == null) return;
      
      // Get current sensors from scanner
      final sensors = await _scanner!.getSensors();
      
      // Clear and rebuild device list
      _discoveredDevices.clear();
      
      // Convert to BrainBitDevice objects
      for (final sensorInfo in sensors) {
        if (sensorInfo != null) {
          final device = BrainBitDevice.fromFSensorInfo(sensorInfo);
          if (!_discoveredDevices.any((d) => d.id == device.id)) {
            _discoveredDevices.add(device);
          }
        }
      }
      
      // Notify listeners
      _deviceController.add(List.from(_discoveredDevices));
      
    } catch (e) {
      print('Error updating device list: $e');
    }
  }

  /// Manually adds a discovered device (for testing or custom discovery)
  void addDiscoveredDevice(FSensorInfo sensorInfo) {
    final device = BrainBitDevice.fromFSensorInfo(sensorInfo);
    
    // Avoid duplicates
    if (!_discoveredDevices.any((d) => d.id == device.id)) {
      _discoveredDevices.add(device);
      _deviceController.add(List.from(_discoveredDevices));
    }
  }

  /// Gets device by ID
  BrainBitDevice? getDeviceById(String id) {
    try {
      return _discoveredDevices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clears all discovered devices
  void clearDevices() {
    _discoveredDevices.clear();
    _deviceController.add([]);
  }

  /// Disposes resources and stops scanning
  Future<void> dispose() async {
    await stopScanning();
    
    _scanner?.dispose();
    _scanner = null;
    
    await _deviceController.close();
    await _scanningController.close();
  }
}

/// Custom exception for scanner-related errors
class BrainBitScannerException implements Exception {
  final String message;
  
  const BrainBitScannerException(this.message);
  
  @override
  String toString() => 'BrainBitScannerException: $message';
}
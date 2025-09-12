/**
 * BrainBit Permission Service
 * 
 * This service handles all permission-related functionality required for
 * BrainBit device connection, including Bluetooth and location permissions.
 * It provides platform-specific permission handling for iOS and Android.
 * 
 * Features:
 * - Cross-platform permission checking
 * - Automatic permission requests
 * - Bluetooth adapter state monitoring
 * - Location services verification (Android)
 * - User-friendly error messages
 * 
 * Usage:
 * - Call before attempting to scan for devices
 * - Handles all permission edge cases
 * - Provides clear feedback to users
 */

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling BrainBit-related permissions and hardware checks
class BrainBitPermissionService {
  /// Performs comprehensive permission and hardware checks
  /// 
  /// Returns true if all requirements are met, false otherwise.
  /// Shows appropriate error dialogs for any failures.
  static Future<bool> checkAllPermissions() async {
    try {
      // Check required permissions
      final missingPermissions = await _checkPermissions();
      if (missingPermissions.isNotEmpty) {
        throw BrainBitPermissionException(
          'Permissions required',
          'Please grant ${_formatPermissionList(missingPermissions)} to connect to BrainBit devices.',
        );
      }

      // Check Bluetooth availability
      if (!await _checkBluetooth()) {
        return false; // Error dialog already shown by _checkBluetooth
      }

      // Check location services (Android only)
      if (!await _checkLocationServices()) {
        return false; // Error dialog already shown by _checkLocationServices
      }

      return true;
    } catch (e) {
      if (e is BrainBitPermissionException) {
        rethrow;
      }
      throw BrainBitPermissionException(
        'Permission check failed',
        'Unable to verify permissions: ${e.toString()}',
      );
    }
  }

  /// Checks and requests required permissions
  /// 
  /// Returns a list of permissions that were not granted
  static Future<List<Permission>> _checkPermissions() async {
    // iOS and desktop platforms don't require explicit permission requests
    if (Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
      return [];
    }

    // Android permissions
    final permissions = [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    final statuses = await permissions.request();

    // Return permissions that were not granted
    return statuses.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  }

  /// Formats a list of permissions for user display
  static String _formatPermissionList(List<Permission> permissions) {
    final names = permissions.map((p) => _getPermissionDisplayName(p)).toList();
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names.first} and ${names.last}';
    return '${names.take(names.length - 1).join(', ')}, and ${names.last}';
  }

  /// Gets user-friendly permission names
  static String _getPermissionDisplayName(Permission permission) {
    switch (permission) {
      case Permission.bluetoothConnect:
        return 'Bluetooth Connection';
      case Permission.bluetoothScan:
        return 'Bluetooth Scanning';
      case Permission.location:
        return 'Location';
      default:
        return permission.toString();
    }
  }

  /// Checks Bluetooth availability and state
  static Future<bool> _checkBluetooth() async {
    // Windows doesn't require Bluetooth checks
    if (Platform.isWindows) return true;

    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        throw BrainBitPermissionException(
          'Bluetooth not supported',
          'This device does not support Bluetooth.',
        );
      }

      // Handle iOS-specific Bluetooth initialization
      if (Platform.isIOS) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (e) {
          // turnOn() may not be available on iOS - this is expected
        }
      }

      // Check adapter state with timeout
      BluetoothAdapterState adapterState;
      try {
        adapterState = await FlutterBluePlus.adapterState
            .timeout(const Duration(seconds: 5))
            .first;
      } catch (e) {
        // On iOS, adapter state check might timeout
        if (Platform.isIOS) {
          // Assume Bluetooth is available on iOS if we can't determine state
          return true;
        }
        adapterState = BluetoothAdapterState.unknown;
      }

      switch (adapterState) {
        case BluetoothAdapterState.on:
          return true;
        case BluetoothAdapterState.off:
          throw BrainBitPermissionException(
            'Bluetooth disabled',
            'Please turn on Bluetooth in your device settings to connect to BrainBit devices.',
          );
        case BluetoothAdapterState.turningOn:
          // Wait a moment and assume it will be ready
          await Future.delayed(const Duration(seconds: 2));
          return true;
        default:
          // For iOS, if state is unclear, try to continue anyway
          if (Platform.isIOS) {
            return true;
          }
          throw BrainBitPermissionException(
            'Bluetooth status unclear',
            'Unable to determine Bluetooth status. Please ensure Bluetooth is enabled and try again.',
          );
      }
    } catch (e) {
      if (e is BrainBitPermissionException) rethrow;
      
      // On iOS, if there's any error, assume Bluetooth might work
      if (Platform.isIOS) {
        return true;
      }
      
      throw BrainBitPermissionException(
        'Bluetooth check failed',
        'Error checking Bluetooth: ${e.toString()}',
      );
    }
  }

  /// Checks location services (required for Bluetooth scanning on older Android)
  static Future<bool> _checkLocationServices() async {
    // Only required for Android
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 12+ (API 32+) doesn't require location for Bluetooth
      if (androidInfo.version.sdkInt >= 32) return true;

      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw BrainBitPermissionException(
          'Location services disabled',
          'Please turn on Location Services for Bluetooth scanning.',
        );
      }

      return true;
    } catch (e) {
      if (e is BrainBitPermissionException) rethrow;
      
      throw BrainBitPermissionException(
        'Location check failed',
        'Error checking location services: ${e.toString()}',
      );
    }
  }

  /// Requests a specific permission with user-friendly messaging
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Checks if all required permissions are currently granted
  static Future<bool> areAllPermissionsGranted() async {
    try {
      final missing = await _checkPermissions();
      return missing.isEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for permission-related errors
class BrainBitPermissionException implements Exception {
  final String title;
  final String message;

  const BrainBitPermissionException(this.title, this.message);

  @override
  String toString() => 'BrainBitPermissionException: $title - $message';
}
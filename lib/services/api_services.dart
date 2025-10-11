import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/user.dart';

class ApiService {
  static String? _cachedBaseUrl;
  static const int serverPort = 3000;

  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    if (Platform.isAndroid) {
      _cachedBaseUrl = 'http://10.0.2.2:$serverPort/api';
    } else {
      // Try localhost first (for iOS Simulator)
      if (await _testConnection('localhost')) {
        _cachedBaseUrl = 'http://localhost:$serverPort/api';
      } else {
        // Fallback to network discovery for physical devices
        final networkIP = await _discoverServerIP();
        _cachedBaseUrl = 'http://$networkIP:$serverPort/api';
      }
    }

    return _cachedBaseUrl!;
  }

  static Future<bool> _testConnection(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:$serverPort/test'),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _discoverServerIP() async {
    // Get the device's current network subnet
    final interfaces = await NetworkInterface.list();

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 &&
            !address.isLoopback &&
            !address.isLinkLocal) {

          // Extract subnet (e.g., 192.168.1.x)
          final parts = address.address.split('.');
          if (parts.length == 4) {
            final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

            // Try common host IPs in the subnet
            final commonHosts = [29, 1, 100, 101, 102, 103, 150, 200];

            for (final host in commonHosts) {
              final testIP = '$subnet.$host';
              if (await _testConnection(testIP)) {
                return testIP;
              }
            }
          }
        }
      }
    }

    // Final fallback
    return 'localhost';
  }

  static void clearCache() {
    _cachedBaseUrl = null;
  }

  Future<AppUser?> getUser(String uid) async {
    final url = await baseUrl;
    final response = await http.get(Uri.parse('$url/users/$uid'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppUser.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<AppUser> createUser(AppUser user) async {
    final url = await baseUrl;
    try {
      final response = await http.post(
        Uri.parse('$url/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppUser.fromJson(data);
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend user creation during login failed: $e');
    }
  }
}

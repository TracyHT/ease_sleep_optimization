import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static String? _cachedBaseUrl;
  static const int serverPort = 3000;

  static const String _railwayBase =
      'https://easesleepoptimization-production.up.railway.app/api';

  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) {
      print('Using cached API URL: $_cachedBaseUrl');
      return _cachedBaseUrl!;
    }

    print('🌍 Discovering best API endpoint...');

    if (Platform.isAndroid) {
      // Emulator Android
      _cachedBaseUrl = 'http://10.0.2.2:$serverPort/api';
      print('🤖 Android emulator detected → $_cachedBaseUrl');
    } else if (Platform.isIOS) {
      // Try localhost for simulator
      if (await _testConnection('localhost')) {
        _cachedBaseUrl = 'http://localhost:$serverPort/api';
        print('🧩 iOS Simulator detected → $_cachedBaseUrl');
      } else {
        // Real device → Railway server
        _cachedBaseUrl = _railwayBase;
        print(
          '📱 Physical iOS device detected → Using Railway: $_cachedBaseUrl',
        );
      }
    } else {
      // Fallback for other platforms (web, macOS, etc.)
      _cachedBaseUrl = _railwayBase;
      print('🖥️ Defaulting to Railway backend: $_cachedBaseUrl');
    }

    return _cachedBaseUrl!;
  }

  /// 🧠 Test if localhost is reachable
  static Future<bool> _testConnection(String ip) async {
    try {
      final testUrl = 'http://$ip:$serverPort/test';
      print('🔎 Testing connection to $testUrl');
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 10));
      final ok = response.statusCode == 200;
      if (ok) print('✅ Localhost connection OK');
      return ok;
    } catch (_) {
      print('❌ Localhost not reachable');
      return false;
    }
  }

  /// 🧹 Clear cache (force rediscovery)
  static void clearCache() {
    _cachedBaseUrl = null;
  }

  /// 👤 Fetch user from backend
  Future<AppUser?> getUser(String uid) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/users/$uid');
    print('📡 Fetching user: $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  /// ✳️ Create user on backend
  Future<AppUser> createUser(AppUser user) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/users');
    print('📤 Creating user: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend user creation failed: $e');
    }
  }
}

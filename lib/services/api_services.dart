import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/user.dart';

class ApiService {
    static final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://192.168.1.103:3000/api';

  Future<AppUser?> getUser(String uid) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$uid'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppUser.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }
}

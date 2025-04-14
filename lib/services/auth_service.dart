import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ IMPORTANT: Use your local IP instead of 'localhost' for Android emulator
  // e.g., replace with actual IP like '192.168.0.102'
  static const String baseUrl = 'http://10.1.186.107:3000'; // For Android emulator

  /// Logs in user using email and phone
  static Future<Map<String, dynamic>> login(String email, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'phone': phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data']?['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['data']['token']);
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  /// Checks if user is already logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }

  /// Returns the stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Logs out the user by removing the token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}

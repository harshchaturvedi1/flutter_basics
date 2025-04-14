import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';

  // Login with email and phone
  static Future<Map<String, dynamic>> login(String email, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['token'] != null) {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return token != null;
  }

  // Get the stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
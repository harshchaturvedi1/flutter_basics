import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  // ✅ IMPORTANT: Use your local IP instead of 'localhost' for Android emulator
  // e.g., replace with actual IP like '192.168.0.102'
  static const String baseUrl = 'http://10.1.186.107:3000'; // For Android emulator
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Generates a nonce for Apple Sign In
  static String _generateNonce() {
    const length = 32;
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return List.generate(length, (i) => charset[i % charset.length]).join();
  }

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Sign in aborted'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'token': googleAuth.idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'providerId': googleUser.id,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data']?['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['data']['token']);
        return {'success': true, 'message': 'Google sign in successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Google sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Google sign in error: ${e.toString()}'};
    }
  }

  /// Sign in with Apple
  static Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/auth/social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'apple',
          'token': credential.identityToken,
          'email': credential.email,
          'name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
          'providerId': credential.userIdentifier,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data']?['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['data']['token']);
        return {'success': true, 'message': 'Apple sign in successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Apple sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Apple sign in error: ${e.toString()}'};
    }
  }

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

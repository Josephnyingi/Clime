import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  /// ✅ **Login Method**
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final Uri url = Uri.parse("$API_BASE_URL/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("phone_number", phone);
        return {"success": true, "message": "Login successful"};
      } else {
        return {"success": false, "message": jsonDecode(response.body)['detail']};
      }
    } catch (error) {
      return {"success": false, "message": "Server error: $error"};
    }
  }

  /// ✅ **Register Method**
  Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    final Uri url = Uri.parse("$API_BASE_URL/users/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone_number": phone, "password": password}),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully!"};
      } else {
        return {"success": false, "message": jsonDecode(response.body)['detail']};
      }
    } catch (error) {
      return {"success": false, "message": "Server error: $error"};
    }
  }
}

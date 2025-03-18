import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart'; // ✅ Import Constants
import '../utils/helpers.dart';   // ✅ Import Helpers

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// ✅ **Check if user is already logged in**
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (isLoggedIn) {
      // If the user is already logged in, redirect to the dashboard
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    }
  }

  /// ✅ **Login User**
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Uri url = Uri.parse("$API_BASE_URL/login/");
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true); // ✅ Store login state
        await prefs.setString("phone_number", phone); // ✅ Store user info if needed

        _showSuccessMessage("Login successful! Redirecting...");
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorMessage(responseData['detail']);
      }
    } catch (error) {
      logMessage("Login failed: $error");
      _showErrorMessage("Failed to connect to the server.");
    }

    setState(() => _isLoading = false);
  }

  /// ✅ **Register User**
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Uri url = Uri.parse("$API_BASE_URL/users/");
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage("User registered successfully! You can now log in.");
        await Future.delayed(const Duration(seconds: 1));
        _toggleMode();
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorMessage(responseData['detail']);
      }
    } catch (error) {
      logMessage("Registration failed: $error");
      _showErrorMessage("Failed to connect to the server.");
    }

    setState(() => _isLoading = false);
  }

  /// ✅ **Show Error Message**
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: const Duration(milliseconds: 500),
        child: AlertDialog(
          title: const Text("Error", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  /// ✅ **Show Success Message**
  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: const Duration(milliseconds: 500),
        child: AlertDialog(
          title: const Text("Success", style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  /// ✅ **Toggle between Login & Register Mode**
  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _isRegistering ? "Create Account" : "Welcome Back",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              if (_isRegistering) ...[
                FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.trim().isEmpty ? 'Enter your name' : null,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.trim().isEmpty ? 'Enter your phone number' : null,
                ),
              ),
              const SizedBox(height: 16.0),
              FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.trim().isEmpty ? 'Enter your password' : null,
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isRegistering ? _register : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: Text(_isRegistering ? 'Register' : 'Login'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isRegistering
                                  ? "Already have an account? Login"
                                  : "Don't have an account? Register",
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

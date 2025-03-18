import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _rememberMe = false;
  bool _obscurePassword = true; // 👁 Password visibility toggle

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
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("phone_number", phone);
        if (_rememberMe) {
          await prefs.setBool("rememberMe", true);
        }

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

  /// ✅ **Toggle Login/Register Mode**
  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering);
  }

  /// ✅ **Handle Forgot Password**
  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: const Duration(milliseconds: 500),
        child: AlertDialog(
          title: const Text("Reset Password"),
          content: const Text("Contact support to reset your password."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ **Anga Logo & Image**
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  'assets/images/farming.jpg', // 📌 Ensure this image exists in assets/images/
                  height: 200,
                ),
              ),
              const SizedBox(height: 15),

              // ✅ **Anga Description**
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: const [
                    Text(
                      "🌍 Anga - AI-Powered Climate Insights",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Accurate AI-driven weather forecasts to help farmers make smarter decisions and increase yields.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ✅ **Login Form**
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.trim().isEmpty ? 'Enter your phone number' : null,
                    ),
                    const SizedBox(height: 16),

                    // ✅ **Password Field with Visibility Toggle**
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value!.trim().isEmpty ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 10),

                    // ✅ **Remember Me & Forgot Password**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) => setState(() => _rememberMe = value!),
                            ),
                            const Text("Remember Me"),
                          ],
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            child: const Text("Login"),
                          ),
                    const SizedBox(height: 10),

                    // ✅ **Switch Between Login/Register**
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(_isRegistering ? "Already have an account? Login" : "Don't have an account? Register"),
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


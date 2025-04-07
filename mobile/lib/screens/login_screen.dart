import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

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
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  /// ✅ **Handle Login**
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final result = await _authService.login(phone, password);

    setState(() => _isLoading = false);

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("phone_number", phone);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _showMessage("Error", result['message'], Colors.red);
    }
  }

  /// ✅ **Handle Register**
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final result = await _authService.register("User", phone, password);

    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage("Success", result['message'], Colors.green);
      _toggleMode();
    } else {
      _showMessage("Error", result['message'], Colors.red);
    }
  }

  /// ✅ **Show Message Dialog**
  void _showMessage(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: const Duration(milliseconds: 500),
        child: AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
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

  /// ✅ **Toggle Between Login/Register Mode**
  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering);
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
                      "🌍 Anga - AI-Powered Climate Forecasts",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Accurate AI-driven weather forecasts to help African farmers make smarter decisions and increase yields.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ✅ **Login/Register Form**
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
                          onPressed: () => _showMessage("Forgot Password", "Contact support to reset your password.", Colors.blue),
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ **Login/Register Button**
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _isRegistering ? _handleRegister : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            child: Text(_isRegistering ? "Register" : "Login"),
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

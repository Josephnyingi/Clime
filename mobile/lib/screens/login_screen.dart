import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
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
    // ❌ No SharedPreferences check
  }

  /// ✅ Handle Login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final result = await _authService.login(phone, password);

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _showMessage("Error", result['message'], Colors.red);
    }
  }

  /// ✅ Handle Register
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

  /// ✅ Show Message Dialog
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

  /// ✅ Toggle Login/Register Mode
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
              // ✅ Logo or image
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  'assets/images/farming.jpg',
                  height: 200,
                ),
              ),
              const SizedBox(height: 15),

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) => setState(() => _rememberMe = value!),
                            ),
                            const Text("Remember Me"), // 📝 UI only for now
                          ],
                        ),
                        TextButton(
                          onPressed: () => _showMessage("Forgot Password", "Contact support to reset your password.", Colors.blue),
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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


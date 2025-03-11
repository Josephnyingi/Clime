import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    final Uri url = Uri.parse("http://127.0.0.1:8000/login/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage("Login successful! Redirecting...");
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorMessage(responseData['detail']);
      }
    } catch (error) {
      _showErrorMessage("Failed to connect to the server.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String name = _nameController.text;
    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    final Uri url = Uri.parse("http://127.0.0.1:8000/users/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage("User registered successfully! You can now log in.");
        await Future.delayed(Duration(seconds: 1));
        _toggleMode();
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorMessage(responseData['detail']);
      }
    } catch (error) {
      _showErrorMessage("Failed to connect to the server.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: Duration(milliseconds: 500),
        child: AlertDialog(
          title: Text("Error", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: Duration(milliseconds: 500),
        child: AlertDialog(
          title: Text("Success", style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Register' : 'Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: Duration(milliseconds: 500),
                child: Text(
                  _isRegistering ? "Create Account" : "Welcome Back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              if (_isRegistering) ...[
                FadeInLeft(
                  duration: Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                  ),
                ),
                SizedBox(height: 16.0),
              ],
              FadeInLeft(
                duration: Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Enter your phone number' : null,
                ),
              ),
              SizedBox(height: 16.0),
              FadeInRight(
                duration: Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Enter your password' : null,
                ),
              ),
              SizedBox(height: 24.0),
              _isLoading
                  ? CircularProgressIndicator()
                  : FadeInUp(
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isRegistering ? _register : _login,
                            child: Text(_isRegistering ? 'Register' : 'Login'),
                          ),
                          SizedBox(height: 10),
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

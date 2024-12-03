import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  int _selectedTab = 0; // 0 for Login, 1 for Signup

  Future<void> loginUser(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Query the CPADUSER table for the given username and password
      final response = await http.get(
        Uri.parse(
            'https://parseapi.back4app.com/classes/CPADUSER?where=${Uri.encodeComponent(json.encode({"username": username, "password": password}))}'),
        headers: {
          'X-Parse-Application-Id': 'app_id',
          'X-Parse-REST-API-Key': 'api_key',
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          Navigator.pushReplacementNamed(context, '/tasks');
        } else {
          _showDialog('Login Failed', 'Invalid username or password.');
        }
      } else {
        _showDialog('Error', 'Failed to connect to the server.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  Future<void> signupUser(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add a new user to the CPADUSER table
      final response = await http.post(
        Uri.parse('https://parseapi.back4app.com/classes/CPADUSER'),
        headers: {
          'X-Parse-Application-Id': 'app_id',
          'X-Parse-REST-API-Key': 'api_key',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        _showDialog(
          'Signup Successful',
          'Account created successfully. You can now log in.',
          action: () {
            setState(() {
              _selectedTab = 0; // Switch to Login tab
            });
            Navigator.pop(context);
          },
        );
      } else {
        _showDialog('Signup Failed', 'Error: Unable to create account.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  void _showDialog(String title, String message, {VoidCallback? action}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: action ?? () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
        title: Text('CPAD - QuickTask- 2023MT93200'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tab Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 0; // Login Tab
                      });
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedTab == 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 1; // Signup Tab
                      });
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedTab == 1 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Login/Signup Button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        final username = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          _showDialog('Error', 'Please fill in all fields.');
                          return;
                        }

                        if (_selectedTab == 0) {
                          loginUser(username, password); // Login Function
                        } else {
                          signupUser(username, password); // Signup Function
                        }
                      },
                      child: Text(_selectedTab == 0 ? 'Login' : 'Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

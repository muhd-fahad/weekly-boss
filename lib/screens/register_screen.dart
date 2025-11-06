import 'package:flutter/material.dart';
import 'package:weekly_boss/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();


  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isHidden = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Password cannot be empty.')),
      );
      return;
    }

    try {
      await _authService.registerUser(name, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 768)
            Expanded(child: Container(color: Colors.grey)),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                constraints: BoxConstraints(maxWidth: 450),
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: Icon(
                        Icons.lock_open,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        label: Text('Name'),
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isHidden,
                      decoration: InputDecoration(
                        label: Text('Password'),
                        prefixIcon: Icon(Icons.password),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                          child: Opacity(
                            opacity: 0.5,
                            child: Icon(
                              _isHidden == true
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _registerUser,
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                          ),
                        ),
                        child: Text('Log in', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

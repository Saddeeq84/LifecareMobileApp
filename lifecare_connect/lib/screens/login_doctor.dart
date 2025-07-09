// login_doctor.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'register_role_selection.dart'; // ✅ Link to registration

// 🔒 Firebase temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class LoginDoctorScreen extends StatefulWidget {
  const LoginDoctorScreen({super.key});

  @override
  State<LoginDoctorScreen> createState() => _LoginDoctorScreenState();
}

class _LoginDoctorScreenState extends State<LoginDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated login delay

    // 🔒 TODO: Replace with Firebase role & approval check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Login simulated (no Firebase yet)')),
    );

    setState(() => loading = false);

    // Simulated successful login
    Navigator.pushReplacementNamed(context, '/doctor_dashboard');
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1)); // Simulated reset delay
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset email sent (simulated)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: const Text(
                    'Welcome back, Doctor!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size.fromHeight(45),
                          ),
                          onPressed: loading ? null : handleLogin,
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: resetPassword,
                          child: const Text('Forgot password?'),
                        ),

                        // ✅ Create Account
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterRoleSelectionScreen(),
                              ),
                            );
                          },
                          child: const Text("Don't have an account? Create one"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// This screen allows doctors to log in with their email and password.
// It includes a welcome banner, form fields for email and password, and buttons for login and
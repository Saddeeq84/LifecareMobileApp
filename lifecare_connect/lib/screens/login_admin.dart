// login_admin.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Firebase temporarily disabled (backend not yet integrated)
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({Key? key}) : super(key: key);

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? adminName;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate login

    // 🔒 TODO: Replace with real Firebase auth logic later
    setState(() {
      adminName = 'Admin User';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, $adminName')),
    );

    setState(() => loading = false);

    // Simulated successful login redirect
    Navigator.pushReplacementNamed(context, '/admin_dashboard');
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1)); // simulate reset

    // 🔒 TODO: Replace with Firebase password reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset email sent. Check your inbox.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerText = adminName != null
        ? 'Welcome back, $adminName!'
        : 'Welcome back, Admin!';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              bannerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || !value.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) =>
                          value == null || value.length < 6
                              ? 'Enter 6+ character password'
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
// This screen allows admins to log in with their email and password.
// It includes a welcome banner, form fields for email and password, and buttons for login and
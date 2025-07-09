// login_chw.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Temporarily disabling Firebase, Firestore, and social login packages
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../helpers/auth_helper.dart'; // 🔒 loginAndRedirect() not needed yet

class CHWLoginScreen extends StatefulWidget {
  const CHWLoginScreen({super.key});

  @override
  State<CHWLoginScreen> createState() => _CHWLoginScreenState();
}

class _CHWLoginScreenState extends State<CHWLoginScreen> {
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
    await Future.delayed(const Duration(seconds: 1)); // Simulated login

    // 🔒 TODO: Replace with real authentication logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Login simulated (backend not yet active)')),
    );

    setState(() => loading = false);

    // Simulated navigation
    Navigator.pushReplacementNamed(context, '/chw_dashboard');
  }

  Future<void> loginWithGoogle() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated login

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Google login simulated')),
    );

    setState(() => loading = false);
    Navigator.pushReplacementNamed(context, '/chw_dashboard');
  }

  Future<void> loginWithFacebook() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated login

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Facebook login simulated')),
    );

    setState(() => loading = false);
    Navigator.pushReplacementNamed(context, '/chw_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHW Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Login as Community Health Worker',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter valid email' : null,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🚧 Forgot password not yet implemented')),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
              const Divider(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: loading ? null : loginWithGoogle,
                label: const Text('Login with Google'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.facebook),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: loading ? null : loginWithFacebook,
                label: const Text('Login with Facebook'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This screen allows community health workers to log in with their email and password.
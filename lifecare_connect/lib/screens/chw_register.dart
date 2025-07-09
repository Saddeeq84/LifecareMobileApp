// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Temporarily disabling Firebase imports until backend is ready
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class CHWRegisterScreen extends StatefulWidget {
  const CHWRegisterScreen({super.key});

  @override
  State<CHWRegisterScreen> createState() => _CHWRegisterScreenState();
}

class _CHWRegisterScreenState extends State<CHWRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  // 🔒 Firebase-based registration disabled (UI only)
  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Account registration logic not yet implemented')),
    );
    setState(() => loading = false);
  }

  Future<void> handleGoogleSignUp() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Google sign-up logic not yet implemented')),
    );
    setState(() => loading = false);
  }

  Future<void> handleFacebookSignUp() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Facebook sign-up logic not yet implemented')),
    );
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as a Health Worker'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField('Full Name', fullNameController),
              const SizedBox(height: 10),
              buildTextField(
                'Email',
                emailController,
                validator: (val) =>
                    val != null && val.contains('@') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 10),
              buildTextField(
                'Password',
                passwordController,
                obscure: true,
                validator: (val) =>
                    val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: 10),
              buildTextField(
                'Confirm Password',
                confirmController,
                obscure: true,
                validator: (val) =>
                    val != passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(45),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Or sign up with'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata, size: 28),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: loading ? null : handleGoogleSignUp,
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.facebook),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: loading ? null : handleFacebookSignUp,
                label: const Text('Continue with Facebook'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label),
      validator: validator ??
          (val) => val == null || val.trim().isEmpty ? 'Please enter $label' : null,
    );
  }
}
// This screen allows community health workers to register with their details.
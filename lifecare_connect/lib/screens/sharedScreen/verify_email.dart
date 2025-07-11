// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Firebase disabled for UI-only testing
// import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool loading = false;

  // 🔒 Simulated user state
  final simulatedUser = {
    'emailVerified': false,
    'email': 'user@example.com',
  };

  @override
  void initState() {
    super.initState();
    checkEmailVerification();

    // ⏳ Delayed reminder
    Future.delayed(const Duration(seconds: 5), () {
      if (!isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still waiting for email verification...'),
          ),
        );
      }
    });
  }

  Future<void> checkEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate refresh
    setState(() {
      isEmailVerified = simulatedUser['emailVerified'] as bool;
    });
  }

  Future<void> resendVerification() async {
    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulate email send
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent (simulated)')),
    );

    setState(() => loading = false);
  }

  Future<void> continueIfVerified() async {
    await checkEmailVerification();
    if (isEmailVerified) {
      Navigator.pushReplacementNamed(context, '/upload_license');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not verified yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please verify your email address by clicking the link sent to your inbox.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: loading ? null : resendVerification,
              icon: const Icon(Icons.mail),
              label: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: continueIfVerified,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh & Continue'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
// 🔒 This screen simulates email verification for UI testing purposes.
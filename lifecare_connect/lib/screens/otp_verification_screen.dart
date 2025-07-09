// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Firebase temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final otpController = TextEditingController();
  bool loading = false;

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => loading = true);

    // 🔒 Simulated verification delay
    await Future.delayed(const Duration(seconds: 1));

    // 🔒 TODO: Replace with Firebase verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ OTP verified (simulated)')),
    );

    setState(() => loading = false);

    // Simulated navigation to dashboard
    Navigator.pushReplacementNamed(context, '/patient_dashboard');
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit OTP sent to ${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(45),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
// This screen allows users to verify the OTP sent to their phone number.
// It includes a text field for entering the OTP and a button to verify it.
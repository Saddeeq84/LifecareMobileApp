// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:lifecare_connect/screens/chwscreen/chw_dashboard.dart'; // ✅ Corrected import

class CHWCreateAccountScreen extends StatefulWidget {
  const CHWCreateAccountScreen({super.key});

  @override
  State<CHWCreateAccountScreen> createState() => _CHWCreateAccountScreenState();
}

class _CHWCreateAccountScreenState extends State<CHWCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _isVerifying = false;
  String? _verificationId;
  int _resendToken = 0;
  int _timerSeconds = 60;
  Timer? _countdownTimer;

  void _startCountdown() {
    _timerSeconds = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'community_health_worker',
        'isPhoneVerified': false,
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final token = await FirebaseAppCheck.instance.getToken();
      print('App Check token: $token');

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user.linkWithCredential(credential);
          await _firestore.collection('users').doc(user.uid).update({
            'isPhoneVerified': true,
          });
          await _handleApprovalAndRedirect(user.uid);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _resendToken = resendToken ?? 0;
          });
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📩 OTP sent to your phone')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndLinkPhone() async {
    if (_verificationId == null || otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the OTP code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not found');

      await user.linkWithCredential(credential);

      await _firestore.collection('users').doc(user.uid).update({
        'isPhoneVerified': true,
      });

      await _handleApprovalAndRedirect(user.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ OTP verification failed: $e')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleApprovalAndRedirect(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final isApproved = doc.data()?['isApproved'] ?? false;

    if (!isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Awaiting admin approval to activate account')),
      );
      await _auth.signOut();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Account approved & phone verified')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CHWDashboard()),
    );
  }

  Future<void> _resendCode() async {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your phone number')),
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resend failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken ?? 0;
          });
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📩 OTP resent')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as CHW'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Full Name', fullNameController),
              const SizedBox(height: 15),
              _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField('Phone (+234)', phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField('Password', passwordController, obscureText: true),
              const SizedBox(height: 15),
              _buildTextField('Confirm Password', confirmPasswordController, obscureText: true),
              const SizedBox(height: 30),
              if (_codeSent) ...[
                _buildTextField('Enter OTP', otpController, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtpAndLinkPhone,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify OTP'),
                ),
                const SizedBox(height: 10),
                if (_timerSeconds == 0)
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text('🔁 Resend Code'),
                  )
                else
                  Text('Resend available in $_timerSeconds seconds'),
              ],
              if (!_codeSent)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account', style: TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) =>
          val == null || val.trim().isEmpty ? 'Please enter $label' : null,
    );
  }
}
// This screen allows CHWs to create an account, verify their phone number, and handle admin approval.
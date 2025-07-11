// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Firebase temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final phoneController = TextEditingController();

  String verificationId = '';
  bool isPhoneMode = false;
  bool loading = false;

  void switchMode(bool usePhone) {
    setState(() => isPhoneMode = usePhone);
  }

  Future<void> verifyPhoneAndRegister() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();

    if (fullName.isEmpty || phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid name and phone number")),
      );
      return;
    }

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    setState(() => loading = false);
    showCodeDialog(fullName, phone);
  }

  void showCodeDialog(String fullName, String phone) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '6-digit code'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() => loading = true);
              await Future.delayed(const Duration(seconds: 1)); // Simulate backend

              Navigator.pop(context); // close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Phone verification successful")),
              );

              setState(() => loading = false);
              Navigator.pop(context); // back to login/home
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> handleEmailRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated account creation

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Patient account created (UI only)')),
    );

    setState(() => loading = false);
    Navigator.pop(context); // Simulated redirect
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text(
          'Register as Patient',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [!isPhoneMode, isPhoneMode],
                onPressed: (index) => switchMode(index == 1),
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.teal,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Use Email'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Use Phone'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 10),

                    if (isPhoneMode)
                      TextFormField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val != null && val.length >= 10
                            ? null
                            : 'Enter a valid phone number',
                      )
                    else ...[
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (val) => val != null && val.contains('@')
                            ? null
                            : 'Enter a valid email',
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        validator: (val) => val != null && val.length >= 6
                            ? null
                            : 'Minimum 6 characters',
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Confirm Password'),
                        validator: (val) =>
                            val != passwordController.text
                                ? 'Passwords do not match'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: loading
                          ? null
                          : () => isPhoneMode
                              ? verifyPhoneAndRegister()
                              : handleEmailRegister(),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Account'),
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
// This screen allows users to register as a patient using either email or phone number.
// It includes a toggle to switch between email and phone registration modes, form fields for user details
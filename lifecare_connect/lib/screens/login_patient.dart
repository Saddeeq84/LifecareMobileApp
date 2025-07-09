// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// 🔒 Firebase and helper functions disabled temporarily
// import 'package:firebase_auth/firebase_auth.dart';
// import '../helpers/auth_helper.dart';
// import 'otp_verification_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPhone = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> handleEmailLogin() async {
    if (!_formKeyEmail.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate login

    // 🔒 TODO: Replace with real Firebase auth
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as $email with password $password (simulated)')),
    );

    setState(() => loading = false);
    Navigator.pushReplacementNamed(context, '/patient_dashboard');
  }

  Future<void> handlePhoneLogin() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1)); // simulate OTP sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent (simulated)')),
    );

    // 🔒 TODO: Replace with real OTP screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Verify OTP")),
          body: const Center(child: Text("🚧 OTP Verification UI coming soon")),
        ),
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset link sent (simulated)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Patient Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Email Login'),
            Tab(text: 'Phone Login'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ Email Login Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKeyEmail,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login with Email',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        val != null && val.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (val) =>
                        val != null && val.length >= 6 ? null : 'Minimum 6 characters',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: loading ? null : handleEmailLogin,
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

          // ✅ Phone Login Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKeyPhone,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login with Phone',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (e.g., +234...)',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: handlePhoneLogin,
                    child: const Text('Send OTP'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// This screen allows users to log in as a patient using either email or phone number.
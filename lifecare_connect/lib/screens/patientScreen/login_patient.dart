// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

import '../chwScreen/login_chw_screen.dart';
import '../adminScreen/login_admin.dart';
import '../doctorScreen/login_doctor.dart';
import '../sharedScreen/register_role_selection.dart';
import 'package:lifecare_connect/screens/facilityScreen/facility_login_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🔐 Handle email/password login
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // On successful login, save the role as "patient"
      await _userService.saveUserRole('patient');

      // Centralized role-based navigation
      await _userService.navigateBasedOnRole(context);

    } catch (e) {
      // Show login failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔷 App Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'LifeCare Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connecting communities to quality healthcare',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 📧 Email & Password Login Section
              const Text(
                'Login with Email & Password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loginUser,
                icon: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.login),
                label: const Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1.2),
              const SizedBox(height: 20),

              // 🔄 Alternative Role-Based Logins
              const Text(
                'Or select your login type:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),

              // 👩‍⚕️ CHW
              ElevatedButton.icon(
                icon: const Icon(Icons.medical_services_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const CHWLoginScreen())),
                label: const Text('Community Health Worker'),
              ),
              const SizedBox(height: 15),

              // 🧑‍⚕️ Patient
              ElevatedButton.icon(
                icon: const Icon(Icons.people_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginPage())),
                label: const Text('Patient'),
              ),
              const SizedBox(height: 15),

              // 👨‍⚕️ Doctor
              ElevatedButton.icon(
                icon: const Icon(Icons.local_hospital_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginDoctorScreen())),
                label: const Text('Doctor'),
              ),
              const SizedBox(height: 15),

              // 🧑‍💼 Admin
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginAdminScreen())),
                label: const Text('Admin'),
              ),
              const SizedBox(height: 15),

              // 🏥 Facility Login
              ElevatedButton.icon(
                icon: const Icon(Icons.business_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const FacilityLoginScreen())),
                label: const Text('Facility / Corporate Login'),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1.2),
              const SizedBox(height: 10),

              // 🔗 Create Account
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterRoleSelectionScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Create one",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRoleAndRedirect();
  }

  Future<void> _checkRoleAndRedirect() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _redirectTo('/login');
      return;
    }

    try {
      final idTokenResult = await user.getIdTokenResult(true);
      final role = idTokenResult.claims?['role'];

      print('✅ Logged in user: ${user.email}');
      print('🎯 Role: $role');

      switch (role) {
        case 'admin':
          _redirectTo('/admin_dashboard');
          break;
        case 'doctor':
          _redirectTo('/doctor_dashboard');
          break;
        case 'chw':
          _redirectTo('/chw_dashboard');
          break;
        case 'patient':
          _redirectTo('/patient_dashboard');
          break;
        case 'facility':
          _redirectTo('/facility_dashboard');
          break;
        default:
          _redirectTo('/login');
      }
    } catch (e) {
      print('❌ Role detection error: $e');
      _redirectTo('/login');
    }
  }

  void _redirectTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    _navigateBasedOnRole();
  }

  Future<void> _navigateBasedOnRole() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    try {
      // Assuming users have a 'role' field in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = snapshot.data()?['role'];

      switch (role) {
        case 'doctor':
          context.go('/doctor_dashboard');
          break;
        case 'patient':
          context.go('/patient_dashboard');
          break;
        case 'chw':
          context.go('/chw_dashboard');
          break;
        case 'admin':
          context.go('/admin_dashboard');
          break;
        case 'facility':
          context.go('/facility_dashboard');
          break;
        default:
          context.go('/login');
          break;
      }
    } catch (e) {
      print('🚨 Error fetching user role: $e');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

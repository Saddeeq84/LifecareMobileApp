import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user info and role when registering or updating role
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': role,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user role: $e');
      rethrow;
    }
  }

  /// Get current user's role
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return null;
    }
  }

  /// Navigate based on user role, with approval check for doctor/facility
  Future<void> navigateBasedOnRole(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || !(doc.data()?.containsKey('role') ?? false)) {
        // No user data or no role assigned — redirect to setup or login
        Navigator.pushReplacementNamed(context, '/setup');
        return;
      }

      final data = doc.data()!;
      final role = data['role'] as String? ?? '';

      // Approval check for doctor and facility roles
      final isApproved = data['isApproved'] as bool? ?? false;
      if ((role == 'doctor' || role == 'facility') && !isApproved) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Pending Approval'),
            content: const Text(
                'Your account is awaiting admin approval. Please check back later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          break;
        case 'chw':
          Navigator.pushReplacementNamed(context, '/chw_dashboard');
          break;
        case 'doctor':
          Navigator.pushReplacementNamed(context, '/doctor_dashboard');
          break;
        case 'patient':
          Navigator.pushReplacementNamed(context, '/patient_dashboard');
          break;
        case 'facility':
          Navigator.pushReplacementNamed(context, '/facility_dashboard');
          break;
        default:
          // Unknown role
          Navigator.pushReplacementNamed(context, '/unknown_role');
      }
    } catch (e) {
      debugPrint('Error during role navigation: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Optional: Add a logout method
  Future<void> logout() async {
    await _auth.signOut();
  }
}

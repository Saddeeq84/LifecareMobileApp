import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save role when registering
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'role': role,
    }, SetOptions(merge: true));
  }

  /// Get current user's role
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['role'];
  }

  /// ✅ Centralized Role-Based Navigation
  Future<void> navigateBasedOnRole(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || !doc.data()!.containsKey('role')) {
      Navigator.pushReplacementNamed(context, '/setup'); // Optional profile setup page
      return;
    }

    final role = doc['role'];

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
        Navigator.pushReplacementNamed(context, '/unknown_role');
    }
  }
}

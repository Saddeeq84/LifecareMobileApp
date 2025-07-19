// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import dashboards/screens
import '../screens/adminscreen/admin_dashboard.dart';
import '../screens/chwscreen/chw_dashboard.dart';
import '../screens/patientscreen/patient_dashboard.dart';
import '../screens/doctorscreen/doctor_dashboard.dart';
import '../screens/facilityscreen/facility_dashboard.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update the user's role in Firestore
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'role': role,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Error saving user role: $e');
        rethrow;
      }
    }
  }

  /// Retrieve the currently logged-in user's role
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data()?['role'] as String?;
        }
      } catch (e) {
        debugPrint('❌ Error getting user role: $e');
      }
    }
    return null;
  }

  /// Navigate user to their dashboard based on role and approval (if needed)
  Future<void> navigateBasedOnRole(BuildContext context) async {
    final user = _auth.currentUser;

    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data()?['role'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role not found.')),
        );
        return;
      }

      final data = doc.data()!;
      final String role = data['role'];
      final bool isApproved = data['isApproved'] ?? false;

      // Roles that require admin approval
      const approvalRequiredRoles = ['chw', 'doctor', 'facility'];

      if (approvalRequiredRoles.contains(role) && !isApproved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account is awaiting admin approval. Please try again later.',
            ),
          ),
        );
        await _auth.signOut();
        return;
      }

      // Navigate based on role
      switch (role) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
          break;
        case 'chw':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CHWDashboard()),
          );
          break;
        case 'patient':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PatientDashboard()),
          );
          break;
        case 'doctor':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorDashboard()),
          );
          break;
        case 'facility':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FacilityDashboard()),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown role. Please contact support.')),
          );
      }
    } catch (e) {
      debugPrint('❌ Error navigating based on role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }
}

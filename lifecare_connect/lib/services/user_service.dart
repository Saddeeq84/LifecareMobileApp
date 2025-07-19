// ignore_for_file: avoid_print, use_rethrow_when_possible, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _cachedUserRole;

  /// Returns the cached user role or null if not fetched yet
  String? get cachedUserRole => _cachedUserRole;

  /// Fetches the current user's role from Firestore and caches it
  Future<String?> fetchUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      _cachedUserRole = null;
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _cachedUserRole = doc.data()?['role'] as String?;
        return _cachedUserRole;
      } else {
        _cachedUserRole = null;
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      _cachedUserRole = null;
      return null;
    }
  }

  /// Saves the user's role to Firestore and updates the cache
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'role': role,
      });
      _cachedUserRole = role;
    } catch (e) {
      print('Error saving user role: $e');
      throw e;
    }
  }

  /// Navigates to the appropriate screen based on user role
  Future<void> navigateBasedOnRole(BuildContext context) async {
    final role = _cachedUserRole ?? await fetchUserRole();
    
    if (role == null) {
      // Handle case where role is not found
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    switch (role.toLowerCase()) {
      case 'admin':
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
        break;
      case 'doctor':
        Navigator.of(context).pushReplacementNamed('/doctor_dashboard');
        break;
      case 'patient':
        Navigator.of(context).pushReplacementNamed('/patient_dashboard');
        break;
      case 'nurse':
        Navigator.of(context).pushReplacementNamed('/nurse_dashboard');
        break;
      default:
        // Handle unknown role
        Navigator.of(context).pushReplacementNamed('/role_selection');
        break;
    }
  }
}

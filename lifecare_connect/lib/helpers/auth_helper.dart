// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';

// NOTE: Firebase imports are commented out since you're in UI-only mode.
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> loginAndRedirect({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    // 🔧 Simulate a short loading delay
    await Future.delayed(Duration(seconds: 1));

    // 🔧 Simulate logic based on email content
    String role;

    if (email.contains('chw')) {
      role = 'CHW';
    } else if (email.contains('supervisor')) {
      role = 'supervisor';
    } else {
      role = 'patient';
    }

    // 🔁 Simulated redirection
    if (role == 'CHW') {
      Navigator.pushReplacementNamed(context, '/chw_dashboard');
    } else if (role == 'patient') {
      Navigator.pushReplacementNamed(context, '/patient_dashboard');
    } else if (role == 'supervisor') {
      Navigator.pushReplacementNamed(context, '/supervisor_dashboard');
    } else {
      throw Exception('User role not defined.');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}

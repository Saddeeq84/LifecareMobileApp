import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../sharedscreen/facility_register_widget.dart';

class OwnerRegisterFacilityScreen extends StatefulWidget {
  const OwnerRegisterFacilityScreen({super.key});

  @override
  State<OwnerRegisterFacilityScreen> createState() =>
      _OwnerRegisterFacilityScreenState();
}

class _OwnerRegisterFacilityScreenState
    extends State<OwnerRegisterFacilityScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit({
    required String name,
    required String location,
    required String type,
    required String contactPerson,
    required String email,
    required String phone,
    required File? registrationDocument,
  }) async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('facilities').add({
        'name': name,
        'location': location,
        'type': type,
        'createdBy': user?.uid ?? 'unknown_owner',
        'isApproved': false, 
        'createdAt': FieldValue.serverTimestamp(),
        'contactPerson': contactPerson,
        'email': email,
        'phone': phone,
        // You can also upload registrationDocument to storage and save the URL here if needed
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Facility submitted for approval."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Submission failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Your Facility"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FacilityRegisterWidget(
          isSubmitting: _isSubmitting,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}
// This code defines a screen for facility owners to register their facilities.
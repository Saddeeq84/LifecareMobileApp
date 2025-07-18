import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../sharedscreen/facility_register_screen.dart';

class AdminRegisterFacilityScreen extends StatefulWidget {
  const AdminRegisterFacilityScreen({super.key});

  @override
  State<AdminRegisterFacilityScreen> createState() =>
      _AdminRegisterFacilityScreenState();
}

class _AdminRegisterFacilityScreenState
    extends State<AdminRegisterFacilityScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit({
    required String name,
    required String location,
    required String type,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('facilities').add({
        'name': name,
        'location': location,
        'type': type,
        'createdBy': 'admin',
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Facility registered successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
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
        title: const Text("Register Facility"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FacilityForm(
          isSubmitting: _isSubmitting,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}

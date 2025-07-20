import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../sharedscreen/facility_register_widget.dart';

class AdminRegisterFacilityScreen extends StatefulWidget {
  const AdminRegisterFacilityScreen({super.key});

  @override
  State<AdminRegisterFacilityScreen> createState() =>
      _AdminRegisterFacilityScreenState();
}

class _AdminRegisterFacilityScreenState
    extends State<AdminRegisterFacilityScreen> {
  bool _isSubmitting = false;

  Future<String?> _uploadDocument(File file) async {
    try {
      final fileName =
          'facility_documents/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Document upload failed: $e");
      return null;
    }
  }

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

    try {
      String? docUrl;
      if (registrationDocument != null) {
        docUrl = await _uploadDocument(registrationDocument);
      }

      await FirebaseFirestore.instance.collection('facilities').add({
        'name': name.trim(),
        'location': location.trim(),
        'type': type.trim(),
        'createdBy': 'admin',
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'contactPerson': contactPerson.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        if (docUrl != null) 'documentUrl': docUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Facility registered successfully!")),
        );
        Navigator.of(context).pop();
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
        padding: const EdgeInsets.all(20), // ✅ Apply padding directly
        child: FacilityRegisterWidget(
          isSubmitting: _isSubmitting,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}

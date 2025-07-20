// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FacilityRegisterWidget extends StatefulWidget {
  final bool isSubmitting;
  final Future<void> Function({
    required String name,
    required String location,
    required String type,
    required String contactPerson,
    required String email,
    required String phone,
    required File? registrationDocument,
  }) onSubmit;

  const FacilityRegisterWidget({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<FacilityRegisterWidget> createState() => _FacilityRegisterWidgetState();
}

class _FacilityRegisterWidgetState extends State<FacilityRegisterWidget> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String location = '';
  String type = '';
  String contactPerson = '';
  String email = '';
  String phone = '';
  File? registrationDocument;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        registrationDocument = File(result.files.single.path!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📄 Document selected")),
      );
    } else {
      // User canceled or failed to pick
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No document selected")),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        name: name,
        location: location,
        type: type,
        contactPerson: contactPerson,
        email: email,
        phone: phone,
        registrationDocument: registrationDocument,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: "Facility Name"),
            onChanged: (val) => name = val.trim(),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Location"),
            onChanged: (val) => location = val.trim(),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Type (e.g. Clinic, Hospital)"),
            onChanged: (val) => type = val.trim(),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Contact Person"),
            onChanged: (val) => contactPerson = val.trim(),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => email = val.trim(),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
              if (!emailRegex.hasMatch(val.trim())) return 'Invalid email';
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Phone Number"),
            keyboardType: TextInputType.phone,
            onChanged: (val) => phone = val.trim(),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: widget.isSubmitting ? null : _pickDocument,
            icon: const Icon(Icons.upload_file),
            label: Text(
              registrationDocument != null
                  ? "Document Selected"
                  : "Upload Registration Document",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submit,
            child: widget.isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit Facility"),
          ),
        ],
      ),
    );
  }
}

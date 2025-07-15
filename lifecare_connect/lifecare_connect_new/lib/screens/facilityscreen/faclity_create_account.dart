// facility_create_account.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore

class FacilityCreateAccountScreen extends StatefulWidget {
  const FacilityCreateAccountScreen({super.key});

  @override
  State<FacilityCreateAccountScreen> createState() =>
      _FacilityCreateAccountScreenState();
}

class _FacilityCreateAccountScreenState extends State<FacilityCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final typeOptions = ['Hospital', 'Pharmacy', 'Laboratory', 'Scan Center'];
  String selectedType = 'Hospital';
  bool _loading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('facilities').add({
        'name': nameController.text.trim(),
        'type': selectedType,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'isApproved': false, // ⛔️ Mark as unapproved initially
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Registration submitted. Awaiting admin approval.')),
      );

      nameController.clear();
      emailController.clear();
      phoneController.clear();
      addressController.clear();
      setState(() {
        selectedType = typeOptions[0];
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to register facility: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Facility"),
        backgroundColor: Colors.teal.shade800,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 100 : 24;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "Fill your facility details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Facility Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter facility name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: typeOptions
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                    decoration: const InputDecoration(labelText: "Facility Type"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      return emailRegex.hasMatch(value) ? null : 'Enter a valid email';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter address' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("📎 Upload simulated (legal doc) – UI only."),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      "Upload Government-Issued Document",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submitForm,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Registration"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

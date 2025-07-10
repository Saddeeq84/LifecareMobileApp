import 'package:flutter/material.dart';

class FacilityRegisterScreen extends StatefulWidget {
  const FacilityRegisterScreen({super.key});

  @override
  State<FacilityRegisterScreen> createState() =>
      _FacilityRegisterScreenState();
}

class _FacilityRegisterScreenState extends State<FacilityRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final typeOptions = ['Hospital', 'Pharmacy', 'Laboratory', 'Scan Center'];
  String selectedType = 'Hospital';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration submitted. Awaiting admin approval."),
        ),
      );

      // Clear all fields after successful "submission"
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      addressController.clear();
      setState(() {
        selectedType = typeOptions[0];
      });

      // Close the form screen (optional)
      Navigator.pop(context);
    }
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
                    validator: (value) => value == null || value.isEmpty ? 'Enter facility name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: typeOptions
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedType = val;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: "Facility Type"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      }
                      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
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
                          content: Text("Upload simulated: Legal document (UI only)"),
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
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      "Submit Registration",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                      foregroundColor: Colors.white,
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
// This code defines a Flutter screen for registering a healthcare facility.
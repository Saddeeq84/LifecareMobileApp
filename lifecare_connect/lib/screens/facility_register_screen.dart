// lib/screens/facility/facility_register_screen.dart
import 'package:flutter/material.dart';

class FacilityRegisterScreen extends StatelessWidget {
  const FacilityRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final typeOptions = ['Hospital', 'Pharmacy', 'Laboratory', 'Scan Center'];
    String selectedType = typeOptions[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Facility"),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text("Fill your facility details", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Facility Name")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => selectedType = val ?? 'Hospital',
              decoration: const InputDecoration(labelText: "Facility Type"),
            ),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate file upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Upload simulated: Legal document (UI only)")),
                );
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Government-Issued Document"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Simulated submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Registration submitted. Awaiting admin approval.")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.send),
              label: const Text("Submit Registration"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
            )
          ],
        ),
      ),
    );
  }
}

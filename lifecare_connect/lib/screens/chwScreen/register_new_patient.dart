import 'package:flutter/material.dart';

class RegisterNewPatientScreen extends StatefulWidget {
  const RegisterNewPatientScreen({super.key});

  @override
  State<RegisterNewPatientScreen> createState() => _RegisterNewPatientScreenState();
}

class _RegisterNewPatientScreenState extends State<RegisterNewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedTrimester;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Form is valid — simulate saving...')),
    );

    // Simulate navigation or success
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Patient'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) =>
                    value == null || value.length < 11 ? 'Enter valid phone number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTrimester,
                items: const [
                  DropdownMenuItem(value: '1st Trimester', child: Text('1st Trimester')),
                  DropdownMenuItem(value: '2nd Trimester', child: Text('2nd Trimester')),
                  DropdownMenuItem(value: '3rd Trimester', child: Text('3rd Trimester')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Trimester',
                  prefixIcon: Icon(Icons.pregnant_woman),
                ),
                onChanged: (value) => setState(() => selectedTrimester = value),
                validator: (value) => value == null ? 'Select trimester' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: _submitForm,
                child: const Text('Register Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This screen allows CHWs to register new patients with basic details.
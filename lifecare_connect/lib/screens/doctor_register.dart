// doctor_register.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 🔒 Temporarily disabling Firebase imports until backend is ready
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedSpecialization;
  File? profileImage;
  bool loading = false;

  final List<String> specializations = [
    'General Practitioner',
    'Pediatrics',
    'Cardiology',
    'Dermatology',
    'Gynecology',
    'Orthopedics',
    'Psychiatry',
    'Radiology',
    'Surgery',
  ];

  Future<void> pickProfilePicture() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your profile picture')),
      );
      return;
    }

    if (selectedSpecialization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your specialization')),
      );
      return;
    }

    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulated delay

    // 🔒 TODO: Replace with Firebase registration logic later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Registration backend not implemented yet'),
      ),
    );

    setState(() => loading = false);

    // Simulated navigation
    // Navigator.pushNamed(context, '/verify_email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.length < 10 ? 'Invalid phone number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val!.contains('@') ? null : 'Invalid email',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val!.length >= 6 ? null : 'Minimum 6 characters',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Specialization'),
                value: selectedSpecialization,
                items: specializations
                    .map((spec) =>
                        DropdownMenuItem(value: spec, child: Text(spec)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSpecialization = val),
                validator: (val) =>
                    val == null ? 'Please select a specialization' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: loading ? null : handleRegister,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This screen allows doctors to register with their details, including profile picture, specialization, and contact information.
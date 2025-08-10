

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifecare_connect/core/utils/email_admin_approval.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class DoctorCreateAccountScreen extends StatefulWidget {
  const DoctorCreateAccountScreen({super.key});

  @override
  State<DoctorCreateAccountScreen> createState() =>
      _DoctorCreateAccountScreenState();
}

class _DoctorCreateAccountScreenState extends State<DoctorCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedSpecialization;
  String? selectedGender;
  DateTime? selectedDOB;
  File? profileImage;
  File? licenseFile;
  bool loading = false;

  final List<String> specializations = [
    'General Practitioner (GP) / Family Physician',
    'Primary Care Physician',
    'Internal Medicine Specialist',
    'Cardiologist',
    'Endocrinologist',
    'Pulmonologist',
    'Nephrologist',
    'Gastroenterologist',
    'Rheumatologist',
    'Infectious Disease Specialist',
    'Hematologist',
    'Oncologist',
    'General Surgeon',
    'Orthopedic Surgeon',
    'Neurosurgeon',
    'Cardiothoracic Surgeon',
    'Plastic & Reconstructive Surgeon',
    'ENT Surgeon',
    'Urologist',
    'Obstetrician & Gynecologist (OB/GYN)',
    'Reproductive Endocrinologist',
    'Maternal–Fetal Medicine Specialist',
    'Pediatrician',
    'Pediatric Cardiologist',
    'Pediatric Neurologist',
    'Pediatric Surgeon',
    'Neonatologist',
    'Psychiatrist',
    'Ophthalmologist',
    'Otorhinolaryngologist (ENT Specialist)',
    'Dermatologist',
    'Oral & Maxillofacial Surgeon',
    'Other',
  ];
  String? otherSpecialization;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickProfilePicture() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> pickLicenseFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => licenseFile = File(picked.path));
    }
  }

  Future<void> pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDOB = picked);
    }
  }

  Future<String?> uploadFile(File file, String folderName) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}${file.path.split('/').last}');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {

      return null;
    }
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (profileImage == null || licenseFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (selectedSpecialization == null || selectedGender == null || selectedDOB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all personal information')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      final uid = userCred.user?.uid;
      if (uid == null) throw Exception("User creation failed");

      final imageUrl = await uploadFile(profileImage!, 'doctor_profiles');
      final licenseUrl = await uploadFile(licenseFile!, 'doctor_licenses');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'specialization': selectedSpecialization,
        'gender': selectedGender,
        'dob': selectedDOB!.toIso8601String(),
        'role': 'doctor',
        'imageUrl': imageUrl ?? '',
        'licenseUrl': licenseUrl ?? '',
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

  await FirebaseAppCheck.instance.getToken();

      // Show dialog and send email about admin approval requirement
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Your email has been verified. Your account will require admin approval before it becomes active. You will receive another email once your account is approved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      await sendAdminApprovalRequiredEmail(
        emailController.text.trim(),
        fullNameController.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                validator: (val) =>
                    val != null && val.contains('@') ? null : 'Invalid email',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val != null && val.length >= 6 ? null : 'Minimum 6 characters',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                validator: (val) =>
                    val != passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Specialization'),
                value: selectedSpecialization,
                items: specializations
                    .map((spec) => DropdownMenuItem(value: spec, child: Text(spec)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSpecialization = val;
                    if (val != 'Other') otherSpecialization = null;
                  });
                },
                validator: (val) =>
                    val == null ? 'Please select a specialization' : null,
              ),
              if (selectedSpecialization == 'Other')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Please specify your specialization',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => otherSpecialization = val),
                    validator: (val) {
                      if (selectedSpecialization == 'Other' && (val == null || val.trim().isEmpty)) {
                        return 'Please specify your specialization';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                validator: (val) => val == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDOB != null
                          ? 'DOB: ${selectedDOB!.toLocal()}'.split(' ')[0]
                          : 'Select Date of Birth',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: pickDOB,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick DOB'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickLicenseFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  licenseFile == null
                      ? 'Upload Practicing License'
                      : 'License Selected',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      licenseFile == null ? Colors.grey : Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Submission'),
                            content: const Text('Are you sure you want to register this account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Yes, Register'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          handleRegister();
                        }
                      },
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

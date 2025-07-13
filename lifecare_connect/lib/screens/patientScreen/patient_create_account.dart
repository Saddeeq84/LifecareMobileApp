// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  String gender = 'Female';
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final lgaController = TextEditingController();
  final kinController = TextEditingController();
  final relationshipController = TextEditingController();
  final historyController = TextEditingController();

  File? _imageFile;
  bool loading = false;
  final picker = ImagePicker();

  String? _verificationId;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final fileName = 'patient_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> handlePhoneVerification(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optionally auto-sign in here
        print('✅ Phone auto-verified');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('❌ Phone verification failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
        print('📤 Code sent to $phoneNumber');

        // Ask user to input the received code
        final codeController = TextEditingController();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enter OTP Code'),
            content: TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6-digit Code'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final code = codeController.text.trim();
                  final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId!,
                    smsCode: code,
                  );
                  try {
                    await FirebaseAuth.instance.signInWithCredential(credential);
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('❌ OTP verification failed: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid code, please try again.')),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    String? imageUrl;
    final phone = phoneController.text.trim();

    // Upload image
    if (_imageFile != null) {
      imageUrl = await uploadImage(_imageFile!);
      print('📷 Uploaded image URL: $imageUrl');
    }

    try {
      // 🔒 Firebase App Check token
      final token = await FirebaseAppCheck.instance.getToken();
      print('App Check token: $token');

      // ☎️ Phone verification
      await handlePhoneVerification(phone);

      // 📥 Store patient info
      await FirebaseFirestore.instance.collection('patients').add({
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': gender,
        'phone': phone,
        'address': addressController.text.trim(),
        'lga': lgaController.text.trim(),
        'kin': kinController.text.trim(),
        'relationship': relationshipController.text.trim(),
        'history': historyController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isPhoneVerified': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Patient successfully registered.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to register patient. Try again.')),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField('Full Name', nameController),
              buildTextField('Age', ageController, keyboard: TextInputType.number),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => gender = value!),
              ),
              buildTextField('Phone Number', phoneController, keyboard: TextInputType.phone),
              buildTextField('Address', addressController, maxLines: 2),
              buildTextField('LGA', lgaController),
              buildTextField('Next of Kin', kinController),
              buildTextField('Relationship to Patient', relationshipController),
              buildTextField('Medical Notes / Health History', historyController, maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: loading ? null : handleSubmit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: (val) => val == null || val.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}

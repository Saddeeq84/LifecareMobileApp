// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage; // ✅ Firebase Storage

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

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  /// ✅ Uploads image to Firebase Storage and returns the image URL
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

  /// ✅ Submits form data to Firestore
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    String? imageUrl;

    // ✅ Upload image if selected
    if (_imageFile != null) {
      imageUrl = await uploadImage(_imageFile!);
      print('Uploaded image URL: $imageUrl');
    }

    try {
      // ✅ Add patient record to Firestore
      await FirebaseFirestore.instance.collection('patients').add({
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': gender,
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'lga': lgaController.text.trim(),
        'kin': kinController.text.trim(),
        'relationship': relationshipController.text.trim(),
        'history': historyController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Patient successfully registered.')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Registration error: $e');
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
        title: const Text(
          'Register Patient',
          style: TextStyle(color: Colors.white),
        ),
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

  /// Utility widget for building labeled text fields
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
// End of file: lib/screens/register_patient.dart
// lib/widgets/patient_registration_form.dart

// ignore_for_file: unnecessary_import, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class PatientRegistrationForm extends StatefulWidget {
  final bool isCHW;

  const PatientRegistrationForm({super.key, required this.isCHW});

  @override
  State<PatientRegistrationForm> createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final lgaController = TextEditingController();
  final kinController = TextEditingController();
  final relationshipController = TextEditingController();
  final historyController = TextEditingController();

  String gender = 'Female';
  String? selectedTrimester;
  List<String> selectedConditions = [];
  File? _imageFile;
  Position? _location;
  bool loading = false;
  String? _verificationId;

  final imagePicker = ImagePicker();

  List<String> healthConditions = [
    'Malaria',
    'Anemia',
    'HIV',
    'High Blood Pressure',
    'Diabetes',
  ];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    lgaController.dispose();
    kinController.dispose();
    relationshipController.dispose();
    historyController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await imagePicker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> captureLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final position = await Geolocator.getCurrentPosition();
      setState(() => _location = position);
    }
  }

  Future<String?> uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('patient_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final upload = await ref.putFile(file);
    return await upload.ref.getDownloadURL();
  }

  Future<void> handlePhoneVerification(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (verificationId, _) async {
        _verificationId = verificationId;
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
                  final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId!,
                    smsCode: codeController.text.trim(),
                  );
                  try {
                    await FirebaseAuth.instance.signInWithCredential(credential);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid code, try again.')),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final phone = phoneController.text.trim();
    final chwId = widget.isCHW ? FirebaseAuth.instance.currentUser?.uid : null;
    String? imageUrl;

    if (_imageFile != null) {
      imageUrl = await uploadImage(_imageFile!);
    }

    if (!widget.isCHW) {
      await handlePhoneVerification(phone);
    }

    final patientData = {
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
      'chwId': chwId,
      'trimester': widget.isCHW ? selectedTrimester : null,
      'conditions': widget.isCHW ? selectedConditions : [],
      'location': widget.isCHW && _location != null
          ? {
              'latitude': _location!.latitude,
              'longitude': _location!.longitude,
            }
          : null,
      'isPhoneVerified': !widget.isCHW,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('patients').add(patientData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Patient registered successfully')),
    );
    Navigator.pop(context);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            buildTextField('Address', addressController),
            buildTextField('LGA', lgaController),
            buildTextField('Next of Kin', kinController),
            buildTextField('Relationship to Patient', relationshipController),
            buildTextField('Medical Notes / Health History', historyController, maxLines: 3),
            if (widget.isCHW) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTrimester,
                decoration: const InputDecoration(labelText: 'Trimester'),
                items: const [
                  DropdownMenuItem(value: '1st Trimester', child: Text('1st Trimester')),
                  DropdownMenuItem(value: '2nd Trimester', child: Text('2nd Trimester')),
                  DropdownMenuItem(value: '3rd Trimester', child: Text('3rd Trimester')),
                ],
                onChanged: (val) => setState(() => selectedTrimester = val),
              ),
              const SizedBox(height: 10),
              const Text('Health Conditions:'),
              ...healthConditions.map((condition) => CheckboxListTile(
                    title: Text(condition),
                    value: selectedConditions.contains(condition),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedConditions.add(condition);
                        } else {
                          selectedConditions.remove(condition);
                        }
                      });
                    },
                  )),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Capture Location'),
                onPressed: captureLocation,
              )
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : handleSubmit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register Patient'),
            )
          ],
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

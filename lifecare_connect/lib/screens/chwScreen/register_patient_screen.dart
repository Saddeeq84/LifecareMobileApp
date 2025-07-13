import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class RegisterPatientScreen extends StatelessWidget {
  const RegisterPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Patient')),
      body: const RegisterPatientForm(),
    );
  }
}

class RegisterPatientForm extends StatefulWidget {
  const RegisterPatientForm({super.key});

  @override
  State<RegisterPatientForm> createState() => _RegisterPatientFormState();
}

class _RegisterPatientFormState extends State<RegisterPatientForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedTrimester;
  String selectedGender = 'Female';
  File? _selectedImage;
  Position? _currentPosition;
  final List<String> _selectedConditions = [];
  bool _isLoading = false;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storage = FirebaseStorage.instance;

  final List<String> _healthConditions = [
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() => _currentPosition = position);
  }

  Future<String?> _uploadImage(File file, String chwId) async {
    try {
      final ref = _storage
          .ref()
          .child('patient_photos/${chwId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<bool> _isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📷 Please take a patient photo')));
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📍 Please capture patient location')));
      return;
    }

    if (!await _isConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📡 No internet connection')));
      return;
    }

    final chwId = _authService.currentUser?.uid;
    if (chwId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ User not logged in')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final photoUrl = await _uploadImage(_selectedImage!, chwId);
      if (photoUrl == null) throw Exception('Image upload failed');

      final patientData = {
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()) ?? 0,
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'trimester': selectedTrimester,
        'chwId': chwId,
        'conditions': _selectedConditions,
        'location': {
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
        },
        'photoUrl': photoUrl,
        'createdAt': DateTime.now(),
      };

      await _firestoreService.RegisterPatientScreen(patientData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Patient registered successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Patient registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.shade50,
                  image: _selectedImage != null
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) =>
                  value == null || value.length < 11 ? 'Enter valid phone number' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: const [
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
              ],
              onChanged: (value) => setState(() => selectedGender = value!),
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.transgender),
              ),
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
            const SizedBox(height: 16),
            const Text('Health Conditions:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._healthConditions.map((condition) => CheckboxListTile(
                  title: Text(condition),
                  value: _selectedConditions.contains(condition),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                )),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Capture Location'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: _getCurrentLocation,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Register Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: _submitForm,
                  ),
          ],
        ),
      ),
    );
  }
}


import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart' as file_picker;
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
  String? licenseFileError;
  // Returns the content type for a given file extension (used for web uploads)
  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
  // firebase_auth 6.x does not support fetchSignInMethodsForEmail; always return empty list so registration proceeds.
  Future<List<String>> fetchSignInMethodsForEmailWithErrorHandling(String email) async {
  // NOTE: When firebase_auth supports fetchSignInMethodsForEmail again, restore real check here.
    return [];
  }
  Uint8List? licenseFileBytes;
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedSpecialization;
  String? selectedGender;
  DateTime? selectedDOB;
  final dobController = TextEditingController();
  File? profileImage;
  Uint8List? profileImageBytes;
  String? profileImageName;
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
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          profileImageBytes = bytes;
          profileImageName = picked.name;
          profileImage = null;
        });
      } else {
        setState(() {
          profileImage = File(picked.path);
          profileImageBytes = null;
          profileImageName = null;
        });
      }
    }
  }

  String? licenseFileName;
  String? licenseFileExtension;
  Future<void> pickLicenseFile() async {
  // Use file_picker for all supported file types
    final result = await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  withData: kIsWeb, // get bytes for web uploads
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        licenseFile = File(result.files.single.path!);
        licenseFileName = result.files.single.name;
        licenseFileExtension = result.files.single.extension?.toLowerCase();
        if (kIsWeb && result.files.single.bytes != null) {
          licenseFileBytes = result.files.single.bytes;
        } else {
          licenseFileBytes = null;
        }
      });
    }
  }

  Future<void> pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDOB = picked;
        dobController.text = '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }


  Future<String?> uploadFile(File file, String folderName, {Uint8List? fileBytes, String? fileNameOverride}) async {
    try {
      final fileName = fileNameOverride ?? (kIsWeb ? 'web_upload_${DateTime.now().millisecondsSinceEpoch}' : '${DateTime.now().millisecondsSinceEpoch}${file.path.split('/').last}');
      final ref = FirebaseStorage.instance.ref('$folderName/$fileName');
      if (kIsWeb) {
        if (fileBytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File upload error: No file bytes provided for web upload.')),
            );
          }
          return null;
        }
        // On web, upload using bytes only
        final uploadTask = await ref.putData(fileBytes,
            SettableMetadata(contentType: _getContentType(fileName)));
        return await uploadTask.ref.getDownloadURL();
      } else {
        // On mobile/desktop, upload using File
        final uploadTask = await ref.putFile(file);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload error: $e')),
        );
      }
      return null;
    }
  }

  Future<void> handleRegister() async {

    if (!_formKey.currentState!.validate()) {
      setState(() => loading = false);
      return;
    }

    // License upload is now optional. Show warning if not uploaded.
    if (licenseFile == null) {
      setState(() {
        licenseFileError = 'No license uploaded. You must upload your license before your account can be approved by admin.';
      });
    } else {
      setState(() {
        licenseFileError = null;
      });
    }

  // Check if the email is already registered
    final email = emailController.text.trim();
    final existing = await fetchSignInMethodsForEmailWithErrorHandling(email);
    if (existing.isNotEmpty) {
      final shouldEdit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Already In Use'),
          content: const Text('This email is already in use. Please update your email or cancel to stop.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Update'),
            ),
          ],
        ),
      );
      if (shouldEdit != true) {
        setState(() => loading = false);
        return;
      }
  // Focus the email field for user to update
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() => loading = false);
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

    UserCredential? userCred;
    try {
      // 1. Create user first
      userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      final uid = userCred.user?.uid;
      if (uid == null) throw Exception("User creation failed");

      // 2. Upload license file to user-specific folder (optional)
      String? licenseUrl;
      final licenseFolder = 'user_uploads/$uid/doctor_licenses';
      if (licenseFile != null) {
        if (kIsWeb && licenseFileBytes != null) {
          licenseUrl = await uploadFile(
            File('dummy'),
            licenseFolder,
            fileBytes: licenseFileBytes,
            fileNameOverride: licenseFileName,
          );
        } else {
          licenseUrl = await uploadFile(licenseFile!, licenseFolder);
        }
        if (licenseUrl == null || licenseUrl.isEmpty) {
          throw Exception('License upload failed. Please try again.');
        }
      } else {
        licenseUrl = null;
      }

      // 3. Upload profile image (if any) to user-specific folder
      String? imageUrl;
      final profileFolder = 'user_uploads/$uid/doctor_profiles';
      if (kIsWeb && profileImageBytes != null) {
        imageUrl = await uploadFile(
          File('dummy'),
          profileFolder,
          fileBytes: profileImageBytes,
          fileNameOverride: profileImageName,
        );
      } else if (profileImage != null) {
        imageUrl = await uploadFile(profileImage!, profileFolder);
      }

      // 4. Save user document in Firestore
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
        'isRejected': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseAppCheck.instance.getToken();

      await sendAdminApprovalRequiredEmail(
        emailController.text.trim(),
        fullNameController.text.trim(),
      );

      // Show success message and info dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              licenseFile == null
                ? 'Account created! You must upload your license before your account can be approved by admin.'
                : 'Account created! Your account requires admin approval. You will receive an email when approved.'
            ),
            backgroundColor: Colors.green,
          ),
        );
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: Text(
              licenseFile == null
                ? 'Your registration was successful, but you must upload your license before your account can be approved by admin.'
                : 'Your registration was successful and is pending admin approval. You will receive an email when your account is approved.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        // Clear form fields after successful submission
        fullNameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        dobController.clear();
        setState(() {
          selectedSpecialization = null;
          selectedGender = null;
          selectedDOB = null;
          profileImage = null;
          licenseFile = null;
          licenseFileBytes = null;
          licenseFileName = null;
          licenseFileExtension = null;
          otherSpecialization = null;
        });
        // Keep the form open and empty after submission
      }
    } catch (e) {
      // If user was created but a later step failed, delete the user to prevent ghost accounts
      if (userCred != null && userCred.user != null) {
        try {
          await userCred.user!.delete();
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Registration failed: $e')),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
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
              TextFormField(
                controller: dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickDOB,
                validator: (val) => val == null || val.isEmpty ? 'Select Date of Birth' : null,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickLicenseFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      licenseFile == null
                          ? 'Upload License'
                          : 'Change License',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          licenseFile == null ? Colors.grey : Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Accepted file types: JPG, JPEG, PNG, PDF',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  if (licenseFileError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        licenseFileError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  if (licenseFile != null && licenseFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (licenseFileExtension == 'jpg' || licenseFileExtension == 'jpeg' || licenseFileExtension == 'png')
                            kIsWeb && licenseFileBytes != null
                                ? Image.memory(
                                    licenseFileBytes!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    licenseFile!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                          if (licenseFileExtension == 'pdf')
                            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              licenseFileName!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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

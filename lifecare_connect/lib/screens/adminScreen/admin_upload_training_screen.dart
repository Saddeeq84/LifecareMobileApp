import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUploadTrainingScreen extends StatefulWidget {
  const AdminUploadTrainingScreen({super.key});

  @override
  State<AdminUploadTrainingScreen> createState() => _AdminUploadTrainingScreenState();
}

class _AdminUploadTrainingScreenState extends State<AdminUploadTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedType;
  File? selectedFile;
  bool isLoading = false;

  final List<String> types = ['pdf', 'video', 'article', 'link'];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp4'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  Future<String?> _uploadFileToFirebase(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final fileName = "${selectedType}_${DateTime.now().millisecondsSinceEpoch}";
      final ref = FirebaseStorage.instance
          .ref()
          .child("training_files/${user.uid}/$fileName");

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      return null;
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedType == 'pdf' || selectedType == 'video') {
      if (selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a file")),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      String? fileUrl;

      if (selectedFile != null) {
        fileUrl = await _uploadFileToFirebase(selectedFile!);
        if (fileUrl == null) throw Exception("Failed to upload file");
      }

      await FirebaseFirestore.instance.collection('training_materials').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'type': selectedType,
        'url': fileUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Training material uploaded")),
      );

      titleController.clear();
      descriptionController.clear();
      setState(() {
        selectedType = null;
        selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists && doc.data()?['role'] == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _checkAdminAccess().then((isAdmin) {
      if (!isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unauthorized access")),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Training Material"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                }).toList(),
                onChanged: (value) => setState(() => selectedType = value),
                decoration: const InputDecoration(
                  labelText: "Material Type",
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) => value == null ? 'Select material type' : null,
              ),
              const SizedBox(height: 12),
              if (selectedType == 'pdf' || selectedType == 'video')
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(selectedFile != null ? "File Selected" : "Choose File"),
                ),
              if (selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text("📄 File: ${selectedFile!.path.split('/').last}"),
                ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _uploadMaterial,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Material"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

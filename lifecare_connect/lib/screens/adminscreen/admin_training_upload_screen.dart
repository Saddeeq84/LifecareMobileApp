// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // ✅ Fixed import conflict by adding alias

class AdminTrainingUploadScreen extends StatefulWidget {
  const AdminTrainingUploadScreen({super.key});

  @override
  State<AdminTrainingUploadScreen> createState() => _AdminTrainingUploadScreenState();
}

class _AdminTrainingUploadScreenState extends State<AdminTrainingUploadScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKeyCHW = GlobalKey<FormState>();
  final _formKeyPatient = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = 'pdf';
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: _selectedType == 'video' ? FileType.video : FileType.custom,
      allowedExtensions: _selectedType == 'pdf' ? ['pdf'] : null,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _uploadMaterial(String targetRole, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and select a file.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final fileName = p.basename(_selectedFile!.path); // ✅ Use p.basename instead of basename
      final ref = FirebaseStorage.instance
          .ref()
          .child('training_materials/$targetRole/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await ref.putFile(_selectedFile!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('training_materials').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'url': downloadUrl,
        'type': _selectedType,
        'targetRole': targetRole,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material uploaded successfully.')),
      );

      _titleController.clear();
      _descController.clear();
      setState(() {
        _selectedType = 'pdf';
        _selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildUploadForm(String roleLabel, GlobalKey<FormState> formKey) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Text(
              "Upload Training Material for $roleLabel",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Material Type'),
              items: ['pdf', 'video'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
              onPressed: _pickFile,
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Selected: ${p.basename(_selectedFile!.path)}'), // ✅ Updated here too
              ),
            const SizedBox(height: 20),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Material'),
                    onPressed: () => _uploadMaterial(roleLabel.toLowerCase(), formKey),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Upload Training Materials'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CHWs'),
            Tab(text: 'Patients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadForm('CHW', _formKeyCHW),
          _buildUploadForm('Patient', _formKeyPatient),
        ],
      ),
    );
  }
}

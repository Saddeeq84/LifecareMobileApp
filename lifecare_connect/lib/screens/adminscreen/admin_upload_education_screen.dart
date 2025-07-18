// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminUploadEducationScreen extends StatefulWidget {
  const AdminUploadEducationScreen({super.key});

  @override
  State<AdminUploadEducationScreen> createState() => _AdminUploadEducationScreenState();
}

class _AdminUploadEducationScreenState extends State<AdminUploadEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _contentType = 'video';
  String _language = 'English';
  bool _isLoading = false;
  String? _downloadUrl;
  String? _thumbnailUrl;
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFileToStorage() async {
    if (_selectedFile == null) return;

    final fileName = _selectedFile!.path.split('/').last;
    final ref = FirebaseStorage.instance.ref().child('education_files/$fileName');

    final uploadTask = ref.putFile(_selectedFile!);
    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();

    setState(() => _downloadUrl = url);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file')));
      return;
    }

    setState(() => _isLoading = true);
    await _uploadFileToStorage();

    if (_downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File upload failed')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('education_materials').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'url': _downloadUrl,
        'thumbnailUrl': _thumbnailUrl ?? '',
        'contentType': _contentType,
        'language': _language,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful')));
      _formKey.currentState!.reset();
      setState(() {
        _selectedFile = null;
        _downloadUrl = null;
        _thumbnailUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  Widget _buildPreview() {
    if (_selectedFile == null) return const Text('No file selected');

    final ext = _selectedFile!.path.split('.').last.toLowerCase();

    if (['png', 'jpg', 'jpeg'].contains(ext)) {
      return Image.file(_selectedFile!, height: 150, fit: BoxFit.cover);
    } else if (['mp4', 'mov'].contains(ext)) {
      return const Icon(Icons.video_library, size: 100, color: Colors.grey);
    } else if (['mp3', 'wav'].contains(ext)) {
      return const Icon(Icons.audiotrack, size: 100, color: Colors.grey);
    }

    return const Icon(Icons.insert_drive_file, size: 100, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Education Content")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Select File"),
                  ),
                  const SizedBox(width: 16),
                  if (_selectedFile != null)
                    Expanded(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPreview(),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: _contentType,
                decoration: const InputDecoration(labelText: 'Content Type'),
                items: ['video', 'audio', 'infographic']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => _contentType = val!),
              ),
              DropdownButtonFormField(
                value: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: ['English', 'Hausa']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (val) => setState(() => _language = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(_isLoading ? 'Uploading...' : 'Upload'),
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

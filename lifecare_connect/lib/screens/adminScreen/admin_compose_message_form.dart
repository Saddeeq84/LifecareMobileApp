import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComposeMessageForm extends StatefulWidget {
  const ComposeMessageForm({super.key});

  @override
  State<ComposeMessageForm> createState() => _ComposeMessageFormState();
}

class _ComposeMessageFormState extends State<ComposeMessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _audience = "All";
  File? _selectedFile;

  final List<String> audiences = ["All", "CHWs", "Doctors", "Patients"];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    final filename = "attachments/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final ref = FirebaseStorage.instance.ref(filename);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending message...")));

    String? attachmentUrl;
    if (_selectedFile != null) {
      attachmentUrl = await _uploadFile(_selectedFile!);
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    await FirebaseFirestore.instance.collection('adminMessages').add({
      'title': _titleCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
      'audience': _audience,
      'date': formattedDate,
      'attachmentUrl': attachmentUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent successfully.")));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            const Text(
              "Compose Message",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(labelText: "Message"),
                    maxLines: 4,
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _audience,
                    items: audiences
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _audience = val);
                      }
                    },
                    decoration: const InputDecoration(labelText: "Target Audience"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Attach Image (optional)"),
                  ),
                  if (_selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("Attached: ${_selectedFile!.path.split('/').last}"),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    label: const Text("Send"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

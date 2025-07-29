// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadLicenseScreen extends StatefulWidget {
  const UploadLicenseScreen({super.key});

  @override
  State<UploadLicenseScreen> createState() => _UploadLicenseScreenState();
}

class _UploadLicenseScreenState extends State<UploadLicenseScreen> {
  String? selectedFile;

  Future<void> pickLicenseFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      type: FileType.custom,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = result.files.single.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected file: ${result.files.single.name}')),
      );
    }
  }

  void simulateUpload() {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a license file to upload')),
      );
      return;
    }

    // Simulate success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('License "$selectedFile" submitted (UI only)')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload License'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickLicenseFile,
              icon: Icon(Icons.upload_file),
              label: Text("Pick License File"),
            ),
            if (selectedFile != null) ...[
              SizedBox(height: 20),
              Text("Selected File: $selectedFile"),
            ],
            Spacer(),
            ElevatedButton(
              onPressed: simulateUpload,
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// This screen allows users to upload their license files.
// It includes a button to pick a file and displays the selected file name.
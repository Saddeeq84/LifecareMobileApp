import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FacilityForm extends StatefulWidget {
  final void Function({
    required String name,
    required String location,
    required String type,
    required String email,
    required String phone,
    required String contactPerson,
    required File? registrationDocument,
  }) onSubmit;

  final bool isSubmitting;

  const FacilityForm({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  State<FacilityForm> createState() => _FacilityFormState();
}

class _FacilityFormState extends State<FacilityForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();

  String _selectedType = 'Primary';
  File? _pickedFile;

  final List<String> facilityTypes = [
    'Primary',
    'Secondary',
    'Tertiary',
    'Clinic',
    'Hospital',
    'Pharmacy',
    'Laboratory',
    'Scan Center',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        type: _selectedType,
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        contactPerson: _contactCtrl.text.trim(),
        registrationDocument: _pickedFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Facility Name",
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: "Location (State / LGA)",
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: "Facility Type",
                border: OutlineInputBorder(),
              ),
              items: facilityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return "Required";
                final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
                return emailRegex.hasMatch(val) ? null : "Invalid email";
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactCtrl,
              decoration: const InputDecoration(
                labelText: "Contact Person",
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Govt. Document"),
                  ),
                ),
                const SizedBox(width: 10),
                if (_pickedFile != null)
                  Expanded(
                    child: Text(
                      _pickedFile!.path.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.isSubmitting ? null : _submit,
              icon: widget.isSubmitting
                  ? const CircularProgressIndicator.adaptive()
                  : const Icon(Icons.save),
              label: Text(widget.isSubmitting ? "Saving..." : "Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

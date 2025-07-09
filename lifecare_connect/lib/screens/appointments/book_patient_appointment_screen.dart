import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BookPatientAppointmentScreen extends StatefulWidget {
  const BookPatientAppointmentScreen({super.key});

  @override
  State<BookPatientAppointmentScreen> createState() =>
      _BookPatientAppointmentScreenState();
}

class _BookPatientAppointmentScreenState
    extends State<BookPatientAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  String? selectedType;
  String? selectedProvider;
  List<String> uploadedLabFiles = [];

  void _pickLabResults() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.paths.isNotEmpty) {
      setState(() {
        uploadedLabFiles.addAll(
          result.paths.where((e) => e != null).map((e) => e!.split('/').last),
        );
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (selectedType == null || selectedProvider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select appointment type and provider')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment submitted (simulated)')),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged, {
    String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String fieldKey, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
        onSaved: (val) => formData[fieldKey] = val?.trim(),
      ),
    );
  }

  Widget _buildSmallField(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          onSaved: (val) => formData[label] = val?.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown(
                "Appointment Type",
                ['General', 'ANC', 'PNC', 'Follow-up'],
                (val) => setState(() => selectedType = val),
                value: selectedType,
              ),
              _buildDropdown(
                "Select Provider",
                ['Dr. Yusuf', 'CHW Amina'],
                (val) => setState(() => selectedProvider = val),
                value: selectedProvider,
              ),
              _buildTextField("Reason for Visit", "reason"),
              _buildTextField("Symptoms / Concerns", "symptoms"),
              const SizedBox(height: 12),
              const Text(
                'Vitals (optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSmallField("BP"),
                  _buildSmallField("Pulse"),
                  _buildSmallField("Temp"),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickLabResults,
                icon: Icon(Icons.upload_file),
                label: Text('Upload Lab Results'),
              ),
              if (uploadedLabFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uploadedLabFiles
                        .map((file) => Text('- $file'))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: Size.fromHeight(48),
                ),
                child: Text('Submit Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This code defines a screen for booking patient appointments in a healthcare app.
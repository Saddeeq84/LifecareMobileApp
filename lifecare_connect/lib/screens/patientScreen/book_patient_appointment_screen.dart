import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookPatientAppointmentScreen extends StatefulWidget {
  const BookPatientAppointmentScreen({super.key});

  @override
  State<BookPatientAppointmentScreen> createState() =>
      _BookPatientAppointmentScreenState();
}

class _BookPatientAppointmentScreenState extends State<BookPatientAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};
  String? selectedType;
  String? selectedProvider;
  String? selectedProviderId;
  List<String> uploadedLabFiles = [];
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  bool _isSubmitting = false;
  List<Map<String, String>> availableProviders = [];

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: ['doctor', 'chw'])
        .get();

    setState(() {
      availableProviders = snapshot.docs
          .map((doc) => {
                'name': doc['name'].toString(),
                'uid': doc.id.toString(),
              })
          .toList();
    });
  }

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (selectedProvider == null || selectedProviderId == null || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final appointmentData = {
        'patientId': user.uid,
        'doctor': selectedProvider,
        'doctorId': selectedProviderId,
        'type': selectedType,
        'date': selectedDate.toIso8601String(),
        'status': 'pending',
        'reason': formData['reason'] ?? '',
        'symptoms': formData['symptoms'] ?? '',
        'bp': formData['BP'] ?? '',
        'pulse': formData['Pulse'] ?? '',
        'temp': formData['Temp'] ?? '',
        'uploadedFiles': uploadedLabFiles,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('appointments').add(appointmentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment submitted')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, {String? value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildTextField(String label, String key, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
        onSaved: (val) => formData[key] = val?.trim(),
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
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment'), backgroundColor: Colors.green.shade700),
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
                availableProviders.map((e) => e['name']!).toList(),
                (val) {
                  final match = availableProviders.firstWhere((p) => p['name'] == val);
                  setState(() {
                    selectedProvider = match['name'];
                    selectedProviderId = match['uid'];
                  });
                },
                value: selectedProvider,
              ),
              _buildTextField("Reason for Visit", "reason"),
              _buildTextField("Symptoms / Concerns", "symptoms"),
              const SizedBox(height: 12),
              const Text('Vitals (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSmallField("BP"),
                  _buildSmallField("Pulse"),
                  _buildSmallField("Temp"),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Select Appointment Date"),
                subtitle: Text(formattedDate),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickLabResults,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Lab Results'),
              ),
              if (uploadedLabFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uploadedLabFiles.map((file) => Text('- $file')).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

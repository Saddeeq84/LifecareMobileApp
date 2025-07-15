import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ANCChecklistScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? visitId; // null if adding new
  final Map<String, dynamic>? initialData; // null if adding new

  const ANCChecklistScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.visitId,
    this.initialData,
  });

  @override
  State<ANCChecklistScreen> createState() => _ANCChecklistScreenState();
}

class _ANCChecklistScreenState extends State<ANCChecklistScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bpController;
  late TextEditingController _weightController;
  late TextEditingController _symptomsController;
  late TextEditingController _medicationsController;
  late TextEditingController _notesController;
  DateTime? _nextVisitDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData ?? {};

    _bpController = TextEditingController(text: data['bloodPressure'] ?? '');
    _weightController = TextEditingController(text: data['weight'] ?? '');
    _symptomsController = TextEditingController(text: data['symptoms'] ?? '');
    _medicationsController = TextEditingController(text: data['medications'] ?? '');
    _notesController = TextEditingController(text: data['notes'] ?? '');

    if (data['nextVisitDate'] != null) {
      final nextDate = data['nextVisitDate'];
      if (nextDate is Timestamp) {
        _nextVisitDate = nextDate.toDate();
      } else if (nextDate is DateTime) {
        _nextVisitDate = nextDate;
      }
    }
  }

  @override
  void dispose() {
    _bpController.dispose();
    _weightController.dispose();
    _symptomsController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickNextVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVisitDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _nextVisitDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final visitData = {
      'date': Timestamp.now(),
      'bloodPressure': _bpController.text.trim(),
      'weight': _weightController.text.trim(),
      'symptoms': _symptomsController.text.trim(),
      'medications': _medicationsController.text.trim(),
      'nextVisitDate': _nextVisitDate != null ? Timestamp.fromDate(_nextVisitDate!) : null,
      'notes': _notesController.text.trim(),
      'createdAt': widget.visitId == null ? Timestamp.now() : null,
    };

    try {
      final visitsCollection = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('anc_visits');

      if (widget.visitId == null) {
        // Add new visit
        await visitsCollection.doc().set(visitData);
      } else {
        // Update existing visit
        // Remove null createdAt if updating
        visitData.remove('createdAt');
        await visitsCollection.doc(widget.visitId).update(visitData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.visitId == null
              ? '✅ Visit added successfully'
              : '✅ Visit updated successfully'),
        ),
      );

      Navigator.pop(context, true); // Return true to refresh
    } catch (e) {
      debugPrint('Error saving ANC visit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.patientName} - ANC Checklist ${isEditing ? "(Edit)" : ""}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _bpController,
                decoration: const InputDecoration(
                  labelText: 'Blood Pressure (e.g. 120/80)',
                  prefixIcon: Icon(Icons.favorite),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter BP' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter weight' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Symptoms (optional)',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Medications (optional)',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note_alt),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _nextVisitDate != null
                      ? "Next Visit: ${_nextVisitDate!.toLocal().toString().split(' ')[0]}"
                      : "Pick Next Visit Date",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickNextVisitDate,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Update Visit' : 'Save Visit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: _submitForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ANCChecklistScreen extends StatefulWidget {
  final String? visitId;
  final Map<String, dynamic>? initialData;

  const ANCChecklistScreen({
    super.key,
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
  String? selectedPatientId;
  String? selectedPatientName;

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
    if (!_formKey.currentState!.validate() || selectedPatientId == null) return;

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
          .doc(selectedPatientId)
          .collection('anc_visits');

      if (widget.visitId == null) {
        await visitsCollection.add(visitData);
      } else {
        visitData.remove('createdAt');
        await visitsCollection.doc(widget.visitId).update(visitData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.visitId == null ? 'Visit added' : 'Visit updated')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error saving ANC visit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final snapshot = await FirebaseFirestore.instance.collection('patients').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unnamed',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text("ANC Checklist ${isEditing ? "(Edit)" : ""}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchPatients(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final patients = snapshot.data!;

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedPatientId,
                    items: patients.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem<String>(
                        value: p['id'] as String,
                        child: Text(p['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPatientId = value;
                        selectedPatientName = patients.firstWhere((p) => p['id'] == value)['name'];
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Patient'),
                    validator: (value) => value == null ? 'Please select a patient' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bpController,
                    decoration: const InputDecoration(labelText: 'Blood Pressure'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _symptomsController,
                    decoration: const InputDecoration(labelText: 'Symptoms'),
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: _medicationsController,
                    decoration: const InputDecoration(labelText: 'Medications'),
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
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
                      : ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text("Save Visit"),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

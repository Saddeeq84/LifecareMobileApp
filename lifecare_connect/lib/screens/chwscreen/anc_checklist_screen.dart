// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/health_records_service.dart';

class ANCChecklistScreen extends StatefulWidget {
  final String? visitId;
  final String? recordId; // For editing existing health records
  final Map<String, dynamic>? initialData;

  const ANCChecklistScreen({
    super.key,
    this.visitId,
    this.recordId,
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

    try {
      // Get current CHW info
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('CHW not authenticated');
      }

      // Get CHW name from users collection
      final chwDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final chwName = chwDoc.data()?['name'] ?? 'Unknown CHW';

      // Prepare ANC data
      final ancData = {
        'visitDate': Timestamp.now(),
        'bloodPressure': _bpController.text.trim(),
        'weight': _weightController.text.trim(),
        'symptoms': _symptomsController.text.trim(),
        'medications': _medicationsController.text.trim(),
        'nextVisitDate': _nextVisitDate != null ? Timestamp.fromDate(_nextVisitDate!) : null,
        'notes': _notesController.text.trim(),
        'patientName': selectedPatientName ?? 'Unknown Patient',
      };

      if (widget.recordId != null) {
        // Update existing health record
        await HealthRecordsService.updateANCRecord(
          recordId: widget.recordId!,
          ancData: ancData,
        );
      } else {
        // Create new health record
        await HealthRecordsService.saveANCRecord(
          patientUid: selectedPatientId!,
          chwUid: currentUser.uid,
          chwName: chwName,
          ancData: ancData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.recordId == null 
                ? 'ANC visit saved to patient health records' 
                : 'ANC visit updated in health records'
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/chw_dashboard');
      }
    } catch (e) {
      debugPrint('Error saving ANC visit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    // Get patients created by this CHW or all patients if admin
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('createdBy', isEqualTo: currentUser.uid)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unnamed Patient',
        'email': data['email'] ?? '',
        'phone': data['phone'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text("ANC Checklist ${isEditing ? "(Edit)" : ""}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chw_dashboard');
          },
        ),
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
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text("Save Visit"),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                context.go('/chw_dashboard');
                              },
                              child: const Text("Back to Dashboard"),
                            ),
                          ],
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

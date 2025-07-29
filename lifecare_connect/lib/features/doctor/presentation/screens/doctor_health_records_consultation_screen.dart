import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/data/services/health_records_service.dart';

class DoctorHealthRecordsConsultationScreen extends StatefulWidget {
  final String patientUid;
  final String patientName;

  const DoctorHealthRecordsConsultationScreen({
    super.key,
    required this.patientUid,
    required this.patientName,
  });

  @override
  State<DoctorHealthRecordsConsultationScreen> createState() => _DoctorHealthRecordsConsultationScreenState();
}

class _DoctorHealthRecordsConsultationScreenState extends State<DoctorHealthRecordsConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _followUpController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _medicationsController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  Future<void> _submitConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final consultationData = {
        'diagnosis': _diagnosisController.text.trim(),
        'treatment': _treatmentController.text.trim(),
        'clinicalNotes': _notesController.text.trim(),
        'medications': _medicationsController.text.trim(),
        'followUpInstructions': _followUpController.text.trim(),
        'consultationDate': DateTime.now().toIso8601String(),
        'submittedAt': DateTime.now().toIso8601String(),
      };

      await HealthRecordsService.saveDoctorConsultation(
        patientUid: widget.patientUid,
        doctorUid: user.uid,
        doctorName: user.displayName ?? 'Doctor',
        consultationData: consultationData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Consultation - ${widget.patientName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Patient: ${widget.patientName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Diagnosis
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis *',
                hintText: 'Enter primary and secondary diagnoses',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Diagnosis is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Treatment Plan
            TextFormField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Treatment Plan *',
                hintText: 'Describe the recommended treatment approach',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.healing),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Treatment plan is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Clinical Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Clinical Notes',
                hintText: 'Additional observations and notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            
            // Medications
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(
                labelText: 'Medications',
                hintText: 'Prescribed medications with dosage and instructions',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Follow-up Instructions
            TextFormField(
              controller: _followUpController,
              decoration: const InputDecoration(
                labelText: 'Follow-up Instructions',
                hintText: 'Next appointment, monitoring requirements, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Consultation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Important Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Once submitted, this consultation record cannot be edited or deleted for audit trail compliance.',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

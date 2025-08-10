// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/widgets/patient_list_widget.dart';

class ChwPatientListScreen extends StatelessWidget {
  const ChwPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chw_dashboard');
          },
        ),
      ),
      body: PatientListWidget(
        userRole: 'chw',
        showOnlyOwnPatients: true,
        onPatientTap: (patient) => _showPatientOptions(context, patient),
      ),
    );
  }

  void _showPatientOptions(BuildContext context, DocumentSnapshot patient) {
    final patientData = patient.data() as Map<String, dynamic>;
    final patientName = patientData['name'] ?? patientData['fullName'] ?? 'Unknown Patient';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Patient ID: ${patient.id}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.pregnant_woman, color: Colors.teal),
              title: const Text('ANC Checklist'),
              subtitle: const Text('Document antenatal care visit'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to CHW ANC Consultation Details screen
                context.go('/chw_anc_consultation_details', extra: {
                  'appointmentId': '', // No appointment yet
                  'patientId': patient.id,
                  'patientName': patientName,
                  'appointmentData': {'appointmentType': 'ANC'},
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.teal),
              title: const Text('Health Records'),
              subtitle: const Text('View patient health history'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to health records screen
                context.push('/chw_dashboard/patient_health_records', extra: {
                  'patientId': patient.id,
                  'patientName': patientName,
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.teal),
              title: const Text('Update Patient Info'),
              subtitle: const Text('Edit patient details'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update info for $patientName (Coming soon)')),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

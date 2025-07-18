// lib/screens/doctorscreen/doctor_patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifecare_connect/screens/sharedscreen/patient_list_widget.dart'; // Ensure correct path

class DoctorPatientListScreen extends StatelessWidget {
  const DoctorPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Patients')),
      body: PatientListScreen(
        userRole: 'doctor',
        onPatientTap: (DocumentSnapshot patient) {
          // Navigate to a detail screen or show a bottom sheet
          final data = patient.data() as Map<String, dynamic>;
          final fullName = data['fullName'] ?? 'Unknown';

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Patient: $fullName'),
              content: const Text('Open patient record or take action.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
  // This screen displays a list of patients for doctors
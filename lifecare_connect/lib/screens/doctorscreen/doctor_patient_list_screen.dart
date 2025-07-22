// lib/screens/doctorscreen/doctor_patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifecare_connect/screens/sharedscreen/patient_list_widget.dart';

class DoctorPatientListScreen extends StatelessWidget {
  const DoctorPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: PatientListScreen(
        userRole: 'doctor',
        onPatientTap: (DocumentSnapshot patient) {
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
                    leading: const Icon(Icons.medical_services, color: Colors.teal),
                    title: const Text('Health Records'),
                    subtitle: const Text('View comprehensive health history'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Health records for $patientName (Coming soon)')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.note_add, color: Colors.teal),
                    title: const Text('Add Clinical Notes'),
                    subtitle: const Text('Document consultation findings'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Add notes for $patientName (Coming soon)')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.teal),
                    title: const Text('Prescriptions'),
                    subtitle: const Text('Manage medications and prescriptions'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Prescriptions for $patientName (Coming soon)')),
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
        },
      ),
    );
  }
}
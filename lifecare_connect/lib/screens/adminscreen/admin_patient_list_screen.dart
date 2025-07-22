// screens/adminscreen/admin_patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sharedscreen/patient_list_widget.dart'; 

class AdminPatientListScreen extends StatelessWidget {
  const AdminPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Patients"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: PatientListScreen(
        userRole: 'admin',
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
                    leading: const Icon(Icons.folder_open, color: Colors.teal),
                    title: const Text('Complete Health Records'),
                    subtitle: const Text('View all patient records'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Health records for $patientName (Coming soon)')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.teal),
                    title: const Text('Manage Patient'),
                    subtitle: const Text('Edit or update patient information'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Manage $patientName (Coming soon)')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.teal),
                    title: const Text('Patient Analytics'),
                    subtitle: const Text('View patient statistics and reports'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Analytics for $patientName (Coming soon)')),
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

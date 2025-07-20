// screens/adminscreen/admin_patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sharedscreen/patient_list_widget.dart'; 

class AdminPatientListScreen extends StatelessWidget {
  const AdminPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Patients")),
      body: PatientListScreen(
        userRole: 'admin',
        onPatientTap: (DocumentSnapshot patient) {
          final data = patient.data() as Map<String, dynamic>;
          final name = data['fullName'] ?? 'Unknown';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped patient: $name')),
          );
        },
      ),
    );
  }
}

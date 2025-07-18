import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/sharedscreen/patient_list_widget.dart';

class AdminPatientListScreen extends StatelessWidget {
  const AdminPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Patients")),
      body: PatientListScreen(
        userRole: 'admin',
        onPatientTap: (patient) {
          // TODO: Implement what happens when a patient is tapped
        },
      ),
    );
  }
}

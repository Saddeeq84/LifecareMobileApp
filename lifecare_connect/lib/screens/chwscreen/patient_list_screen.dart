import 'package:flutter/material.dart';
import '../sharedscreen/patient_list_widget.dart'; 

class ChwPatientListScreen extends StatelessWidget {
  const ChwPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patients (CHW View)")),
      body: PatientListScreen(
        userRole: 'chw',
        onPatientTap: (patient) {
          // You can navigate or show dialog here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tapped on ${patient['fullName']}")),
          );
        },
      ),
    );
  }
}

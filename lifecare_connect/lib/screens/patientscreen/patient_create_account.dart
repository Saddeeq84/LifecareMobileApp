import 'package:flutter/material.dart';
import '../sharedscreen/patient_registration_screen.dart';

class PatientSelfRegisterScreen extends StatelessWidget {
  const PatientSelfRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Patient'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: const PatientRegistrationForm(isCHW: false), // 👈 Not a CHW
    );
  }
}
// This screen allows patients to self-register by filling out their details.
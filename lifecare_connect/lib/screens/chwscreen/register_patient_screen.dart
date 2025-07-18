import 'package:flutter/material.dart';
import '../sharedscreen/patient_registration_screen.dart';

class RegisterScreen extends StatelessWidget {
  final bool isCHW;

  const RegisterScreen({super.key, required this.isCHW});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Patient')),
      body: PatientRegistrationForm(isCHW: isCHW),
    );
  }
}

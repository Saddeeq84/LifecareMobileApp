import 'package:flutter/material.dart';
import '../sharedscreen/patient_registration_form.dart';

class PatientRegisterScreen extends StatelessWidget {
  const PatientRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Patient Account'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: const SafeArea(
        child: PatientRegistrationForm(isCHW: false), // Patient self-registering
      ),
    );
  }
}

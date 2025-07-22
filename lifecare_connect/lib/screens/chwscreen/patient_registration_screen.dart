// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../sharedscreen/patient_registration_form.dart';

class PatientRegistrationScreen extends StatelessWidget {
  final bool isCHW;
  
  const PatientRegistrationScreen({super.key, this.isCHW = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCHW ? 'Register New Patient' : 'Create Account'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: PatientRegistrationForm(isCHW: isCHW),
      ),
    );
  }
}

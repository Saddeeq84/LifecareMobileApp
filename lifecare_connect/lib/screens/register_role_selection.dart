// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'chw_register.dart';
import 'login_patient_register.dart';
import 'doctor_register.dart';

class RegisterRoleSelectionScreen extends StatelessWidget {
  const RegisterRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // Top banner
              Container(
                width: double.infinity,
                color: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: const Text(
                  'Take this simple step to join us or access quality care from the comfort of your home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Role Selection Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Account Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Health Worker Button
                    _buildRoleButton(
                      context,
                      label: 'Health Worker',
                      icon: Icons.medical_services_outlined,
                      screen: const CHWRegisterScreen(),
                    ),
                    const SizedBox(height: 20),

                    // Patient Button
                    _buildRoleButton(
                      context,
                      label: 'Patient',
                      icon: Icons.person_outline,
                      screen: const PatientRegisterScreen(),
                    ),
                    const SizedBox(height: 20),

                    // Doctor Button
                    _buildRoleButton(
                      context,
                      label: 'Doctor',
                      icon: Icons.local_hospital_outlined,
                      screen: const DoctorRegisterScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Button Builder
  Widget _buildRoleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}

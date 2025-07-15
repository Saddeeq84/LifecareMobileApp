// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// ✅ Correct imports for each role's registration screen
import 'package:lifecare_connect/screens/chwscreen/chw_create_account.dart';
import 'package:lifecare_connect/screens/patientscreen/login_patient_register.dart';
import 'package:lifecare_connect/screens/doctorscreen/doctor_create_account.dart';
import 'package:lifecare_connect/screens/facilityscreen/faclity_create_account.dart';

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
              // 🟢 Top banner
              Container(
                width: double.infinity,
                color: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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

              // 🧩 Role Selection Section
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

                    // 👩‍⚕️ Community Health Worker
                    _buildRoleButton(
                      context,
                      label: 'Health Worker',
                      icon: Icons.medical_services_outlined,
                      screen: const CHWCreateAccountScreen(), // ✅ Replace if class is CHWRegisterScreen
                    ),
                    const SizedBox(height: 20),

                    // 🧑‍⚕️ Patient
                    _buildRoleButton(
                      context,
                      label: 'Patient',
                      icon: Icons.person_outline,
                      screen: const PatientRegisterScreen(),
                    ),
                    const SizedBox(height: 20),

                    // 👨‍⚕️ Doctor
                    _buildRoleButton(
                      context,
                      label: 'Doctor',
                      icon: Icons.local_hospital_outlined,
                      screen: const DoctorCreateAccountScreen(),
                    ),
                    const SizedBox(height: 20),

                    // 🏥 Facility / Corporate
                    _buildRoleButton(
                      context,
                      label: 'Facility / Corporate',
                      icon: Icons.business_outlined,
                      screen: const FacilityCreateAccountScreen(),
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

  // 🔁 Reusable Button Builder with consistent styling
  Widget _buildRoleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
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

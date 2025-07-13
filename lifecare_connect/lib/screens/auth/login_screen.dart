// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';

// Import the role-specific login screens
import '../chwScreen/login_chw_screen.dart';
import '../patientScreen/login_patient.dart';
import '../adminScreen/login_admin.dart';
import '../doctorScreen/login_doctor.dart';
import '../sharedScreen/register_role_selection.dart';
import 'package:lifecare_connect/screens/facilityScreen/facility_login_screen.dart'; // ✅ Facility Login

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔷 Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'LifeCare Connect',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connecting communities to quality healthcare',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  'Select your login type:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),

                // 👩‍⚕️ CHW Login
                ElevatedButton.icon(
                  icon: const Icon(Icons.medical_services_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white, // ✅ White text & icon
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CHWLoginScreen()),
                    );
                  },
                  label: const Text('Community Health Worker'),
                ),
                const SizedBox(height: 15),

                // 🧑‍⚕️ Patient Login
                ElevatedButton.icon(
                  icon: const Icon(Icons.people_outline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientLoginScreen()),
                    );
                  },
                  label: const Text('Patient'),
                ),
                const SizedBox(height: 15),

                // 👨‍⚕️ Doctor Login
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_hospital_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginDoctorScreen()),
                    );
                  },
                  label: const Text('Doctor'),
                ),
                const SizedBox(height: 15),

                // 🧑‍💼 Admin Login
                ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginAdminScreen()),
                    );
                  },
                  label: const Text('Admin'),
                ),
                const SizedBox(height: 15),

                // 🏥 Facility (Corporate) Login
                ElevatedButton.icon(
                  icon: const Icon(Icons.business_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FacilityLoginScreen()),
                    );
                  },
                  label: const Text('Facility / Corporate Login'),
                ),

                const SizedBox(height: 40),
                const Divider(thickness: 1.2),
                const SizedBox(height: 10),

                // Create Account Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterRoleSelectionScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Create one",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

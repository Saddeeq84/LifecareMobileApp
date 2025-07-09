import 'package:flutter/material.dart';

import 'login_chw.dart';
import 'login_patient.dart';
import 'login_admin.dart';
import 'login_doctor.dart'; // Doctor login screen

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login as:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _buildRoleButton(
                  context,
                  label: 'Community Health Worker',
                  screen: const CHWLoginScreen(),
                ),
                const SizedBox(height: 15),

                _buildRoleButton(
                  context,
                  label: 'Patient',
                  screen: const PatientLoginScreen(),
                ),
                const SizedBox(height: 15),

                _buildRoleButton(
                  context,
                  label: 'Doctor',
                  screen: const LoginDoctorScreen(),
                ),
                const SizedBox(height: 15),

                _buildRoleButton(
                  context,
                  label: 'Admin',
                  screen: const LoginAdminScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {
    required String label,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
// This is the role selection page that allows users to choose their role and navigate to the appropriate login screen.
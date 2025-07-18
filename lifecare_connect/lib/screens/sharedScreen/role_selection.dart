import 'package:flutter/material.dart';

import '../chwscreen/login_chw_screen.dart';
import '../patientscreen/login_patient.dart';
// Make sure the imported file defines a class named LoginPatient.
// If the class is named differently (e.g., LoginPatientScreen), update the import and usage accordingly.
import '../adminscreen/login_admin.dart';
import '../doctorscreen/login_doctor.dart';
import '../facilityscreen/facility_login_screen.dart';

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

                // Button for Community Health Worker Login
                _buildRoleButton(
                  context,
                  label: 'Community Health Worker',
                  screen: const CHWLoginScreen(),
                ),
                const SizedBox(height: 15),

                // Button for Patient Login
                _buildRoleButton(
                  context,
                  label: 'Patient',
                  screen: const LoginPatient(), // <-- Make sure this matches the actual class name
                ),
                const SizedBox(height: 15),

                // Button for Doctor Login
                _buildRoleButton(
                  context,
                  label: 'Doctor',
                  screen: const LoginDoctorScreen(),
                ),
                const SizedBox(height: 15),

                // Button for Admin Login
                _buildRoleButton(
                  context,
                  label: 'Admin',
                  screen: const LoginAdminScreen(),
                ),
                const SizedBox(height: 15),

                // Button for Facility/Corporate Login
                _buildRoleButton(
                  context,
                  label: 'Facility/Corporate Login',
                  screen: const FacilityLoginScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String label,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          // Navigate to the selected role's login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Text(label),
      ),
    );
  }
}
// End of file: lib/screens/sharedScreen/role_selection.dart
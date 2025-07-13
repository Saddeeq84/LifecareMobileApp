import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifecare_connect/screens/adminscreen/admin_analytics_screen.dart';
import 'package:lifecare_connect/screens/patientscreen/login_patient_register.dart';
import 'approval_screen.dart';
import 'admin_facilities_screen.dart';
import 'staff_list_screen.dart'; // Ensure this file exports a class named StaffListScreen
import 'admin_upload_training_screen.dart';
import 'all_appointments_screen.dart';
import 'admin_messages_screen.dart';
import 'referrals_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_register_facility_screen.dart'; // Ensure this file exports a class named AdminRegisterFacilityScreen or update the class name below to match the actual exported class

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget buildButton({
    required BuildContext context,
    required String label,
    IconData? icon,
    required Widget targetScreen,
  }) {
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: const Size.fromHeight(48),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Welcome Admin!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          buildButton(
            context: context,
            label: '🛡️ Approve Accounts',
            icon: Icons.verified_user,
            targetScreen: const ApprovalScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '🏥 Facility Categories',
            icon: Icons.local_hospital,
            targetScreen: const AdminFacilitiesScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '👩‍⚕️ Staff (Doctors, CHWs)',
            icon: Icons.group,
            targetScreen: const StaffListScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '🧑‍🤝‍🧑 Patient Register',
            icon: Icons.person_add,
            targetScreen: const PatientRegisterScreen(), // Make sure PatientRegistrationScreen is defined in patient_register_screen.dart
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '📊 Reports & Analytics',
            icon: Icons.bar_chart,
            targetScreen: const AdminAnalyticsScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '📤 Upload Training Module',
            icon: Icons.upload_file,
            targetScreen: const AdminUploadTrainingScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '📅 View All Appointments',
            icon: Icons.calendar_today,
            targetScreen: const AdminAllAppointmentsScreen(), // Update to the correct class name from all_appointments_screen.dart
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '➕ Register New Facility',
            icon: Icons.add_business,
            targetScreen: const AdminRegisterFacilityScreen(), // Ensure this class exists in admin_register_facility_screen.dart
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '📩 Send Message',
            icon: Icons.message,
            targetScreen: const AdminMessagesScreen(),
          ),
          const SizedBox(height: 10),

          buildButton(
            context: context,
            label: '🔁 View All Referrals',
            icon: Icons.swap_horiz,
            targetScreen: const ReferralsScreen(), // Replace with the actual class name exported from referrals_screen.dart
          ),
          const SizedBox(height: 10),

                  buildButton(
                    context: context,
                    label: '⚙️ Settings',
                    icon: Icons.settings,
                    targetScreen: const AdminSettingsScreen(),
                  ),
                      ],
                    ),
                  );
        }
      }
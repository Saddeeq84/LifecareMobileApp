// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'admin_doctor_list_screen.dart';
import 'admin_chw_list_screen.dart';

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Directory'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Manage Staff',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 🟢 CHW Button
            _buildStaffTile(
              context: context,
              label: 'Community Health Workers',
              icon: Icons.people_outline,
              color: Colors.lightGreen,
              screen: const AdminCHWListScreen(),
            ),
            const SizedBox(height: 20),

            // 🔵 Doctor Button
            _buildStaffTile(
              context: context,
              label: 'Doctors',
              icon: Icons.medical_services_outlined,
              color: Colors.blueAccent,
              screen: const AdminDoctorListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}

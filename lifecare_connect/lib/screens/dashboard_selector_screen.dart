import 'package:flutter/material.dart';

class DashboardSelectorScreen extends StatelessWidget {
  const DashboardSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Dashboard Selector')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Patient Dashboard'),
              onPressed: () => Navigator.pushNamed(context, '/patient_dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('CHW Dashboard'),
              onPressed: () => Navigator.pushNamed(context, '/chw_dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_hospital),
              label: const Text('Doctor Dashboard'),
              onPressed: () => Navigator.pushNamed(context, '/doctor_dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin Dashboard'),
              onPressed: () => Navigator.pushNamed(context, '/admin_dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// This code defines a screen that allows users to select between different dashboards (Patient, CHW, Doctor, Admin).
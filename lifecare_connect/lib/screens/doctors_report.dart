import 'package:flutter/material.dart';

class DoctorReportsScreen extends StatelessWidget {
  const DoctorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Summary cards
            _buildStatCard('Total Consultations', '32', Icons.medical_services),
            const SizedBox(height: 15),
            _buildStatCard('Appointments Attended', '18', Icons.calendar_today),
            const SizedBox(height: 15),
            _buildStatCard('Referrals Made', '7', Icons.send),

            const SizedBox(height: 30),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.teal),
              title: const Text('Teleconsultation with Halima Usman'),
              subtitle: const Text('July 26, 2025 • 3:00 PM'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.orange),
              title: const Text('Referral to Gombe Specialist Hospital'),
              subtitle: const Text('July 24, 2025'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Appointment with Ahmed Bala'),
              subtitle: const Text('July 22, 2025 • 11:00 AM'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(title),
      ),
    );
  }
}
// This file defines the DoctorReportsScreen widget, which displays an overview of a doctor's reports and analytics.
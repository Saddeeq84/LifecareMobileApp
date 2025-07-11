import 'package:flutter/material.dart';

class CHWReportsScreen extends StatelessWidget {
  const CHWReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Summary'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: const [
            ReportCard(
              icon: Icons.person,
              label: 'Patients Registered',
              count: 120,
              color: Colors.teal,
            ),
            ReportCard(
              icon: Icons.check_circle,
              label: 'ANC / PNC Visits',
              count: 75,
              color: Colors.purple,
            ),
            ReportCard(
              icon: Icons.send,
              label: 'Referrals Made',
              count: 18,
              color: Colors.orange,
            ),
            ReportCard(
              icon: Icons.video_call,
              label: 'Teleconsults',
              count: 9,
              color: Colors.blue,
            ),
            ReportCard(
              icon: Icons.library_books,
              label: 'Training Sessions',
              count: 5,
              color: Colors.green,
            ),
            ReportCard(
              icon: Icons.vaccines,
              label: 'Immunizations',
              count: 30,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const ReportCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
// This screen displays a summary of various reports relevant to CHWs, such as patient registrations, visits, referrals, and training sessions.
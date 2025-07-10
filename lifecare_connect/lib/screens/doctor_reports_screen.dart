// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

class DoctorReportsScreen extends StatelessWidget {
  const DoctorReportsScreen({super.key});

  final List<Map<String, String>> activityLog = const [
    {
      "title": "Referred patient to cardiology unit",
      "date": "2025-07-09",
    },
    {
      "title": "Reviewed 3 ANC cases from CHWs",
      "date": "2025-07-08",
    },
    {
      "title": "Added clinical note for Grace Danjuma",
      "date": "2025-07-08",
    },
    {
      "title": "Conducted teleconsult with Fatima Bello",
      "date": "2025-07-07",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Activity"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                ReportCard(label: "Consults", count: 12, icon: Icons.video_call),
                ReportCard(label: "Referrals", count: 5, icon: Icons.send_to_mobile),
                ReportCard(label: "Notes Added", count: 8, icon: Icons.note_alt),
                ReportCard(label: "Patients", count: 10, icon: Icons.person),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...activityLog.map((log) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: const Icon(Icons.check_circle_outline, color: Colors.teal),
                title: Text(log["title"]!),
                subtitle: Text(log["date"]!),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const ReportCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.indigo),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(count.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

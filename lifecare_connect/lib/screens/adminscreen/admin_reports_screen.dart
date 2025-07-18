import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> metrics = [
      {"title": "Registered Users", "count": 1200, "icon": Icons.people},
      {"title": "Health Facilities", "count": 86, "icon": Icons.local_hospital},
      {"title": "Referrals", "count": 237, "icon": Icons.transfer_within_a_station},
      {"title": "Appointments", "count": 325, "icon": Icons.calendar_today},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Reports"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "System Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: metrics.map((m) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m["icon"], size: 32, color: Colors.deepPurple.shade800),
                      const SizedBox(height: 8),
                      Text(
                        "${m["count"]}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        m["title"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Monthly Summary (Placeholder)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Chart or Data Summary UI here",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Detailed reports coming soon")),
                );
              },
              icon: const Icon(Icons.description),
              label: const Text("View Full Reports"),
            ),
          ],
        ),
      ),
    );
  }
}
// This file defines the Admin Reports screen for the app.
// It includes a summary of key metrics and a placeholder for detailed reports.
// lib/screens/facility/facility_dashboard.dart
import 'package:flutter/material.dart';

class FacilityDashboard extends StatelessWidget {
  const FacilityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.calendar_today, "label": "Bookings", "route": "/facility_bookings"},
      {"icon": Icons.chat, "label": "Messages", "route": "/facility_messages"},
      {"icon": Icons.settings, "label": "Settings", "route": "/facility_settings"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Facility Dashboard"),
        backgroundColor: Colors.teal.shade800,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: items.map((item) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item['route']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"], size: 40, color: Colors.teal.shade800),
                  const SizedBox(height: 10),
                  Text(item["label"], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

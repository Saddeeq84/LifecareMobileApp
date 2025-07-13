// lib/screens/facility/facility_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication

class FacilityDashboard extends StatelessWidget {
  const FacilityDashboard({super.key});

  // Define a list of dashboard items with icon, label, and navigation route
  List<Map<String, dynamic>> get dashboardItems => [
        {
          "icon": Icons.calendar_today,
          "label": "Bookings",
          "route": "/facility_bookings"
        },
        {
          "icon": Icons.chat,
          "label": "Messages",
          "route": "/facility_messages"
        },
        {
          "icon": Icons.settings,
          "label": "Settings",
          "route": "/facility_settings"
        },
      ];

  // Handle logout using Firebase Auth
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out user
      // Navigate to login screen after logout
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Show error if sign out fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facility Dashboard"),
        backgroundColor: Colors.teal.shade800,
        actions: [
          // Logout button
          IconButton(
            onPressed: () => _handleLogout(context),
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
        children: dashboardItems.map((item) {
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
                  Icon(
                    item["icon"],
                    size: 40,
                    color: Colors.teal.shade800,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item["label"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
// This code defines a simple facility dashboard with navigation and logout functionality.
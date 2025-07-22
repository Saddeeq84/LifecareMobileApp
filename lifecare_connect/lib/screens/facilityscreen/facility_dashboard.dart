// lib/screens/facility/facility_dashboard.dart

// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

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
          "icon": Icons.account_balance_wallet,
          "label": "Wallet",
          "route": "/wallet"
        },
        {
          "icon": Icons.message,
          "label": "Messages",
          "route": "/facility_messages_chat"
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

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upcoming, color: Colors.teal),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: Text(
          '$feature feature is under development and will be available in a future update.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
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
            onTap: () {
              if (item['route'] == '/wallet') {
                _showComingSoonDialog(context, 'Wallet');
              } else if (item['route'] == '/facility_messages_chat') {
                _showComingSoonDialog(context, 'Messages');
              } else {
                Navigator.pushNamed(context, item['route']);
              }
            },
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
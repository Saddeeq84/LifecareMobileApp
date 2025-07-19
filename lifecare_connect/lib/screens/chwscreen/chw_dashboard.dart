// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../sharedscreen/chat_screen.dart'; 

class CHWDashboard extends StatelessWidget {
  const CHWDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDashboardButton(
                context,
                icon: Icons.person_add_alt_1,
                label: 'Register a Patient',
                onTap: () {
                  // TODO: Navigate to Register Patient screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.assignment_turned_in,
                label: 'ANC/PNC Checklist',
                onTap: () {
                  // TODO: Navigate to Checklist screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.account_circle,
                label: 'Profile',
                onTap: () {
                  // TODO: Navigate to Profile screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  // TODO: Navigate to Settings screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.group,
                label: 'My Patients',
                onTap: () {
                  // TODO: Navigate to My Patients screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.calendar_today,
                label: 'Appointments',
                onTap: () {
                  // TODO: Navigate to Appointments screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.share,
                label: 'Referrals',
                onTap: () {
                  // TODO: Navigate to Referrals screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.insert_chart,
                label: 'Reports',
                onTap: () {
                  // TODO: Navigate to Reports screen
                },
              ),
              _buildDashboardButton(
                context,
                icon: Icons.chat,
                label: 'Chat with Doctor',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        currentUserId: 'chw456',
                        receiverId: 'doctor123',
                        receiverName: 'Dr. Yusuf',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48) / 2; // For 2 items per row with spacing

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: buttonWidth,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal.shade900),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal.shade900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

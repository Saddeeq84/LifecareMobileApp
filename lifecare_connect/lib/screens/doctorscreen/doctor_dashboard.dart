// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../sharedscreen/chat_screen.dart'; // 

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome, Dr. ${user.email ?? 'User'}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _doctorDashboardItems.length,
                itemBuilder: (context, index) {
                  final item = _doctorDashboardItems[index];
                  return DashboardTile(
                    icon: item.icon,
                    label: item.label,
                    onTap: () {
                      if (item.label == 'Messages') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              currentUserId: user?.uid ?? 'doctor123', // fallback
                              receiverId: 'chw456', // ✅ Replace with dynamic CHW ID if available
                              receiverName: 'CHW Aisha', // ✅ Replace with actual name if dynamic
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, item.route);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.shade50,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigo.shade800),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardItem {
  final IconData icon;
  final String label;
  final String route;

  const DashboardItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<DashboardItem> _doctorDashboardItems = [
  DashboardItem(
    icon: Icons.people,
    label: 'My Patients',
    route: '/doctor_patients',
  ),
  DashboardItem(
    icon: Icons.calendar_today,
    label: 'Scheduled Consults',
    route: '/doctor_schedule',
  ),
  DashboardItem(
    icon: Icons.send_to_mobile,
    label: 'Review Referrals',
    route: '/doctor_referrals',
  ),
  DashboardItem(
    icon: Icons.note,
    label: 'Medical Notes',
    route: '/doctor_notes',
  ),
  DashboardItem(
    icon: Icons.library_books,
    label: 'Clinical Resources',
    route: '/doctor_resources',
  ),
  DashboardItem(
    icon: Icons.bar_chart,
    label: 'Reports & Analytics',
    route: '/doctor_reports',
  ),
  DashboardItem(
    icon: Icons.chat,
    label: 'Messages',
    route: '/chat_selection', // not used in this case, but kept for structure
  ),
  DashboardItem(
    icon: Icons.person,
    label: 'Profile',
    route: '/doctor_profile',
  ),
];
// This file defines the Doctor Dashboard screen with a grid of options
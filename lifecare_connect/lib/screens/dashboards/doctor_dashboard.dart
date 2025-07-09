// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: _dashboardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = _dashboardItems[index];
            return DashboardCard(
              icon: item.icon,
              label: item.label,
              color: item.color,
              onTap: () => Navigator.pushNamed(context, item.route),
            );
          },
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
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
  final Color color;

  const DashboardItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

const List<DashboardItem> _dashboardItems = [
  DashboardItem(
    icon: Icons.video_call_outlined,
    label: 'My Consultations',
    route: '/doctor_consultations',
    color: Colors.indigo,
  ),
  DashboardItem(
    icon: Icons.assignment_outlined,
    label: 'Referrals',
    route: '/doctor_referrals',
    color: Colors.orange,
  ),
  DashboardItem(
    icon: Icons.calendar_today_outlined,
    label: 'Appointments',
    route: '/doctor_appointments',
    color: Colors.green,
  ),
  DashboardItem(
    icon: Icons.analytics_outlined,
    label: 'Reports',
    route: '/doctor_reports',
    color: Colors.deepPurple,
  ),
];
// This screen serves as the main dashboard for doctors, providing access to various functionalities like consultations, referrals, appointments, and reports.
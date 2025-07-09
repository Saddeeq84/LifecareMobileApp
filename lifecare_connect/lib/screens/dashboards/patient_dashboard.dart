// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../my_health_screen.dart'; // ✅ My Health UI
import 'package:lifecare_connect/screens/appointments/patient_appointment_screen.dart'; // ✅ Appointments screen
import 'package:lifecare_connect/screens/patient_education_screen.dart'; // ✅ Health Education screen
import 'package:lifecare_connect/screens/daily_health_tips_screen.dart';
import 'package:lifecare_connect/screens/chat_with_chw_screen.dart';
import 'package:lifecare_connect/screens/patient_messages_screen.dart';
import 'package:lifecare_connect/screens/patient_profile_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  final List<_DashboardPage> _pages = [
    _DashboardPage(
      title: 'My Health',
      icon: Icons.health_and_safety_outlined,
      content: MyHealthScreen(),
    ),
    _DashboardPage(
      title: 'Appointments',
      icon: Icons.calendar_today_outlined,
      content: PatientAppointmentsScreen(),
    ),
    _DashboardPage(
      title: 'Education',
      icon: Icons.school_outlined,
      content: PatientEducationScreen(), // ✅ Added tab for Health Education
    ),
      _DashboardPage(
    title: 'Daily Tips',
    icon: Icons.tips_and_updates_outlined,
    content: DailyHealthTipsScreen(), // ✅ New tab added here
  ),
    _DashboardPage(
  title: 'Messages',
  icon: Icons.chat_bubble_outline,
  content: PatientMessagesScreen(), // ✅ Updated
),
    _DashboardPage(
    title: 'Chat',
    icon: Icons.chat_outlined,
    content: ChatWithCHWScreen(), // ✅ New tab added here
  ),
_DashboardPage(
  title: 'Profile',
  icon: Icons.person_outline,
  content: PatientProfileScreen(), // ✅ Updated
),
  ];

  void _logout() {
    // 🔁 Simulated logout flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulated logout')),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentPage.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: currentPage.content,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _pages.map((page) {
          return BottomNavigationBarItem(
            icon: Icon(page.icon),
            label: page.title,
          );
        }).toList(),
      ),
    );
  }
}

class _DashboardPage {
  final String title;
  final IconData icon;
  final Widget content;

  const _DashboardPage({
    required this.title,
    required this.icon,
    required this.content,
  });
}

// This code defines a patient dashboard with navigation to different sections like My Health, Appointments, Education, Messages, and Profile.
// admin_dashboard.dart
// ignore_for_file: use_build_context_synchronously, prefer_const_declarations

import 'package:flutter/material.dart';

// 🔒 Firebase disabled temporarily
// import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // 🔒 Simulated user data
  final Map<String, String> simulatedUser = {
    'email': 'admin@example.com',
    'uid': 'ABC123XYZ',
  };

  final List<Widget> _pages = [
    const AdminOverviewPage(),
    const CHWActivityPage(),
    const ReportsPage(),
    const ProfilePage(),
  ];

  void logout() async {
    // 🔒 Simulate logout
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'CHWs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ========== Individual Pages ==========

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔒 Simulated email display
    final simulatedEmail = 'admin@example.com';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text('Logged in as: $simulatedEmail'),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text('Total CHWs Registered'),
              subtitle: Text('Coming soon...'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Pending Approvals'),
              subtitle: Text('Coming soon...'),
            ),
          ),
        ],
      ),
    );
  }
}

class CHWActivityPage extends StatelessWidget {
  const CHWActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Community Health Workers Activity - Coming soon'),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports and Analytics - Coming soon'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔒 Simulated user info
    final simulatedEmail = 'admin@example.com';
    final simulatedUID = 'ABC123XYZ';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person, size: 60, color: Colors.teal),
          const SizedBox(height: 20),
          Text('Email: $simulatedEmail'),
          const SizedBox(height: 10),
          Text('UID: $simulatedUID'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
// This file is part of the LifeCare Connect project.
// It implements the admin dashboard with navigation and simulated user data.
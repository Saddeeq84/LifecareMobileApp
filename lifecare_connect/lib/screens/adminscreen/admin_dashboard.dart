// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminDocument();
      _fetchAdminName();
    });
  }

  Future<void> _checkAdminDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Admin user exists but no Firestore document was found."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _fetchAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data()!;
      setState(() {
        _adminName = data['name'] ?? 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.push('/admin/settings');
                  break;
                case 'logout':
                  _confirmLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              'Welcome, $_adminName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DashboardTile(
              icon: Icons.person,
              title: 'Approve Accounts',
              subtitle: 'Review all pending account requests',
              onTap: () => context.push('/admin/approvals_screen'),
            ),
            DashboardTile(
              icon: Icons.list_alt,
              title: 'Patient List',
              subtitle: 'View all registered patients',
              onTap: () => context.push('/admin/patient_list'),
            ),
            DashboardTile(
              icon: Icons.local_hospital,
              title: 'Registered Health Facilities',
              subtitle: 'View all facilities in categorized tabs',
              onTap: () => context.push('/admin/facility'),
            ),
            DashboardTile(
              icon: Icons.add_business,
              title: 'Register Health Facility',
              subtitle: 'Add a new health facility to the system',
              onTap: () => context.push('/register_facility'),
            ),
            DashboardTile(
              icon: Icons.people,
              title: 'Staff List',
              subtitle: 'Doctors and Community Health Workers',
              onTap: () => context.push('/admin/staff'),
            ),
            DashboardTile(
              icon: Icons.event_available,
              title: 'Appointments',
              subtitle: 'View all scheduled appointments',
              onTap: () => context.push('/admin/appointments'),
            ),
            DashboardTile(
              icon: Icons.compare_arrows,
              title: 'Referrals',
              subtitle: 'View all patient referrals',
              onTap: () => context.push('/admin/referrals'),
            ),
            DashboardTile(
              icon: Icons.school,
              title: 'Training Materials',
              subtitle: 'View or upload training materials',
              onTap: () => context.push('/admin/upload_training'),
            ),
            DashboardTile(
              icon: Icons.message,
              title: 'Messages',
              subtitle: 'View and manage messages',
              onTap: () => context.push('/admin/messages'),
            ),
            DashboardTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View system analytics and insights',
              onTap: () => context.push('/admin/analytics'),
            ),
            DashboardTile(
              icon: Icons.account_balance,
              title: 'Finance',
              subtitle: 'Manage financial transactions',
              onTap: () => _showComingSoonDialog(context, 'Finance'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Logout"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go('/login');
      }
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
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

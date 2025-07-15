import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login'); // Use GoRouter to redirect after logout
  }

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        label: '🛡️ Approve Accounts',
        icon: Icons.verified_user,
        route: '/admin/approve_accounts',
      ),
      _DashboardItem(
        label: '🏥 Health Facilities',
        icon: Icons.local_hospital,
        route: '/admin/health_facilities',
      ),
      _DashboardItem(
        label: '👩‍⚕️ Staff (Doctors, CHWs)',
        icon: Icons.group,
        route: '/admin/staff_list',
      ),
      _DashboardItem(
        label: '🧑‍🤝‍🧑 Patient Register',
        icon: Icons.people,
        route: '/admin/patient_list',
      ),
      _DashboardItem(
        label: '📊 Reports & Analytics',
        icon: Icons.bar_chart,
        route: '/admin/analytics',
      ),
      _DashboardItem(
        label: '📤 Upload Training Module',
        icon: Icons.upload_file,
        route: '/admin/upload_training',
      ),
      _DashboardItem(
        label: '📅 View All Appointments',
        icon: Icons.calendar_today,
        route: '/admin/all_appointments',
      ),
      _DashboardItem(
        label: '➕ Register New Facility',
        icon: Icons.add_business,
        route: '/admin/register_facility',
      ),
      _DashboardItem(
        label: '📩 Send Message',
        icon: Icons.message,
        route: '/admin/messages',
      ),
      _DashboardItem(
        label: '🔁 View All Referrals',
        icon: Icons.swap_horiz,
        route: '/admin/referrals',
      ),
      _DashboardItem(
        label: '⚙️ Settings',
        icon: Icons.settings,
        route: '/admin/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                context.push(item.route); // Use GoRouter to navigate
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 32, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String label;
  final IconData icon;
  final String route;

  const _DashboardItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

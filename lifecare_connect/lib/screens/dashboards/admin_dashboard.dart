import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/admin/all_appointments_screen.dart';
import 'package:lifecare_connect/screens/admin/admin_upload_education_screen.dart'; // ✅ Import your new upload screen

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out (UI only)")),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _navigate(BuildContext context, String route) {
    if (route == '/admin_appointments') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAllAppointmentsScreen()),
      );
    } else if (route == '/admin_upload_education') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUploadEducationScreen()),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: _adminItems.map((item) {
            return DashboardTile(
              icon: item.icon,
              label: item.label,
              onTap: () => _navigate(context, item.route),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Reusable tile widget
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal.shade800),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard item model
class AdminDashboardItem {
  final IconData icon;
  final String label;
  final String route;

  const AdminDashboardItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// ✅ FULL LIST OF ADMIN FEATURES INCLUDING NEW "Upload Education"
const List<AdminDashboardItem> _adminItems = [
  AdminDashboardItem(icon: Icons.people, label: "Manage Users", route: "/admin_manage_users"),
  AdminDashboardItem(icon: Icons.local_hospital, label: "Facilities", route: "/admin_facilities"),
  AdminDashboardItem(icon: Icons.calendar_month, label: "All Appointments", route: "/admin_appointments"),
  AdminDashboardItem(icon: Icons.bar_chart, label: "Reports", route: "/admin_reports"),
  AdminDashboardItem(icon: Icons.school, label: "Training Modules", route: "/admin_training"),
  AdminDashboardItem(icon: Icons.message, label: "Messages", route: "/admin_messages"),
  AdminDashboardItem(icon: Icons.settings, label: "Settings", route: "/admin_settings"),
  AdminDashboardItem(icon: Icons.upload_file, label: "Upload Education", route: "/admin_upload_education"), // ✅ NEW
];

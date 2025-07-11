import 'package:flutter/material.dart';
import '../chwScreen/chw_my_patients_screen.dart'; // Make sure this path is correct

class CHWDashboard extends StatelessWidget {
  const CHWDashboard({super.key});

  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully (simulated)')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'CHW Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            final item = _dashboardItems[index];
            return DashboardTile(
              icon: item.icon,
              label: item.label,
              onTap: () {
                if (item.route == '/chw_my_patients') {
                  // Navigate to CHWMyPatientsScreen with MaterialPageRoute
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CHWMyPatientsScreen(),
                    ),
                  );
                } else {
                  // Navigate by named route for others
                  Navigator.pushNamed(context, item.route);
                }
              },
            );
          },
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
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade50,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
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

const List<DashboardItem> _dashboardItems = [
  DashboardItem(icon: Icons.person_add_alt_1, label: 'Register Patient', route: '/register_patient'),
  DashboardItem(icon: Icons.checklist, label: 'ANC / PNC Checklist', route: '/anc_checklist'),
  DashboardItem(icon: Icons.calendar_today, label: 'Upcoming Visits', route: '/chw_visits'),
  DashboardItem(icon: Icons.video_call, label: 'Referrals & Teleconsult', route: '/referrals'),
  DashboardItem(icon: Icons.library_books, label: 'Training & Education', route: '/training_education'),
  DashboardItem(icon: Icons.bar_chart, label: 'Reports', route: '/chw_reports'),
  DashboardItem(icon: Icons.schedule, label: 'Schedule Appointment', route: '/chw_appointments'),
  DashboardItem(icon: Icons.chat, label: 'Chat', route: '/chat_selection'),
  DashboardItem(icon: Icons.people, label: 'My Patients', route: '/chw_my_patients'),
  DashboardItem(icon: Icons.chat_bubble_outline, label: 'Messages', route: '/chw_messages'),
  DashboardItem(icon: Icons.person_outline, label: 'My Profile', route: '/chw_profile'),
  DashboardItem(icon: Icons.settings, label: 'Settings', route: '/chw_settings'),
];
// End of file: lib/screens/dashboards/chw_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _showFacilityDropdown = false;
  bool _showStaffDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ Approve Accounts - Overview Only
            DashboardTile(
              icon: Icons.person,
              title: 'Approve Accounts',
              subtitle: 'Review all pending account requests',
              onTap: () => context.push('/admin/approve_accounts'),
            ),

            // ✅ Patient List
            DashboardTile(
              icon: Icons.list_alt,
              title: 'Patient List',
              subtitle: 'View all registered patients',
              onTap: () => context.push('/admin/patient_list'),
            ),

            // ✅ Registered Health Facilities Dropdown
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_hospital, size: 32, color: Colors.teal),
                    title: const Text('Registered Health Facilities', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Hospitals, Labs, Pharmacies, Scan Centers'),
                    trailing: Icon(
                      _showFacilityDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        _showFacilityDropdown = !_showFacilityDropdown;
                      });
                    },
                  ),
                  if (_showFacilityDropdown)
                    Column(
                      children: [
                        _buildSubOption(context, 'Hospitals', '/admin/facilities/hospitals'),
                        _buildSubOption(context, 'Laboratories', '/admin/facilities/laboratories'),
                        _buildSubOption(context, 'Pharmacies', '/admin/facilities/pharmacies'),
                        _buildSubOption(context, 'Scan Centers', '/admin/facilities/scan_centers'),
                      ],
                    ),
                ],
              ),
            ),

            // ✅ Staff List Dropdown
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people, size: 32, color: Colors.teal),
                    title: const Text('Staff List', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Doctors, CHWs'),
                    trailing: Icon(
                      _showStaffDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        _showStaffDropdown = !_showStaffDropdown;
                      });
                    },
                  ),
                  if (_showStaffDropdown)
                    Column(
                      children: [
                        _buildSubOption(context, 'Doctors', '/admin/staff/doctors'),
                        _buildSubOption(context, 'CHWs', '/admin/staff/chws'),
                      ],
                    ),
                ],
              ),
            ),

            // ✅ Analytics
            DashboardTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View app usage and performance metrics',
              onTap: () => context.push('/admin/analytics'),
            ),

            // ✅ Settings
            DashboardTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Manage system and platform settings',
              onTap: () => context.push('/admin/settings'),
            ),

            // ✅ Logout
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () async {
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubOption(BuildContext context, String label, String routeName) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.push(routeName),
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

import 'package:flutter/material.dart';

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

            DashboardTile(
              icon: Icons.person,
              title: 'Approve Accounts',
              subtitle: 'Review and approve pending staff or user accounts',
              onTap: () => Navigator.pushNamed(context, '/admin/approve_accounts'),
            ),

            DashboardTile(
              icon: Icons.list_alt,
              title: 'Patient List',
              subtitle: 'View all registered patients',
              onTap: () => Navigator.pushNamed(context, '/admin/patient_list'),
            ),

            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_hospital, size: 32, color: Colors.teal),
                    title: const Text('Registered Health Facilities', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Hospitals, Labs, Pharmacies, Scan Centers'),
                    trailing: Icon(_showFacilityDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
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

            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people, size: 32, color: Colors.teal),
                    title: const Text('Staff List', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Doctors, CHWs'),
                    trailing: Icon(_showStaffDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
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

            DashboardTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View app usage and performance metrics',
              onTap: () => Navigator.pushNamed(context, '/admin/analytics'),
            ),

            DashboardTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Manage system and platform settings',
              onTap: () => Navigator.pushNamed(context, '/admin/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubOption(BuildContext context, String label, String routeName) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, routeName),
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

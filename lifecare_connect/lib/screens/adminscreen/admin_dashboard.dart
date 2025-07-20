import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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

            // ✅ Updated Appointments Tile
            DashboardTile(
              icon: Icons.event_available, 
              title: 'Appointments',
              subtitle: 'View all scheduled appointments',
              onTap: () => context.push('/admin/appointments'),
            ),

            DashboardTile(
              icon: Icons.compare_arrows, // 🔄 More intuitive for 'referrals'
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
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Manage system and platform settings',
              onTap: () => context.push('/admin/settings'),
            ),
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

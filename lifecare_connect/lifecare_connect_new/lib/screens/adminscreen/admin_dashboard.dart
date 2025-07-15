import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'approval_screen.dart';
import 'admin_facilities_screen.dart';
import 'staff_list_screen.dart';
import 'admin_upload_training_screen.dart';
import 'all_appointments_screen.dart';
import 'admin_messages_screen.dart';
import 'referrals_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_register_facility_screen.dart';
import 'admin_analytics_screen.dart';
import 'patient_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Future.microtask(() => context.go('/login'));
  }

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem('🛡️ Approve Accounts', Icons.verified_user, const ApprovalScreen()),
      _DashboardItem('🏥 Health Facilities', Icons.local_hospital, const AdminFacilitiesScreen()),
      _DashboardItem('👩‍⚕️ Staff (Doctors, CHWs)', Icons.group, const StaffListScreen()),
      _DashboardItem('🧑‍🤝‍🧑 Patient Register', Icons.people, const PatientListScreen()),
      _DashboardItem('📊 Reports & Analytics', Icons.bar_chart, const AdminAnalyticsScreen()),
      _DashboardItem('📤 Upload Training Module', Icons.upload_file, const AdminUploadTrainingScreen()),
      _DashboardItem('📅 View All Appointments', Icons.calendar_today, const AdminAllAppointmentsScreen()),
      _DashboardItem('➕ Register New Facility', Icons.add_business, const AdminRegisterFacilityScreen()),
      _DashboardItem('📩 Send Message', Icons.message, const AdminMessagesScreen()),
      _DashboardItem('🔁 View All Referrals', Icons.swap_horiz, const ReferralsScreen()),
      _DashboardItem('⚙️ Settings', Icons.settings, const AdminSettingsScreen()),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => item.targetScreen));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 32, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(item.label, style: const TextStyle(fontSize: 14, color: Colors.white), textAlign: TextAlign.center),
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
  final Widget targetScreen;

  _DashboardItem(this.label, this.icon, this.targetScreen);
}

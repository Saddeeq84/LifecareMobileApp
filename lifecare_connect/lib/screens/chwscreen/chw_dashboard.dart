// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'chw_training_screen.dart';

class CHWDashboard extends StatelessWidget {
  const CHWDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;
    final buttonWidth = isSmallScreen ? screenWidth - 32 : (screenWidth - 48) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
                case 'logout':
                  _confirmLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDashboardButton(
                  context,
                  icon: Icons.person_add_alt_1,
                  label: 'Register a Patient',
                  onTap: () => context.push('/chw/register_patient'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.assignment_turned_in,
                  label: 'ANC/PNC Checklist',
                  onTap: () {
                    print('🔄 Navigating to ANC checklist...');
                    context.go('/anc_checklist');
                  },
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.group,
                  label: 'My Patients',
                  onTap: () => context.push('/my_patients'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  onTap: () => context.go('/chw_appointments'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.share,
                  label: 'Referrals',
                  onTap: () => context.push('/referrals'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.school,
                  label: 'Training & Education',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CHWTrainingScreen()),
                  ),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () => context.push('/messages'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  onTap: () => _showComingSoonDialog(context, 'Wallet'),
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.video_call,
                  label: 'Consultation',
                  onTap: () {
                    print('🔘 CHW Consultation button clicked!');
                    context.push('/chw_consultation');
                  },
                  width: buttonWidth,
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.smart_toy,
                  label: 'AI Chatbot',
                  onTap: () => _showComingSoonDialog(context, 'AI Chatbot'),
                  width: buttonWidth,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal.shade900),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal.shade900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await FirebaseAuth.instance.signOut();
              context.go('/login'); // GoRouter logout
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upcoming, color: Colors.blue),
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

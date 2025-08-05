// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'patient_appointment_screen.dart';
import 'patient_education_screen.dart';
import 'my_health_tab.dart';
import 'package:lifecare_connect/features/patient/presentation/screens/patient_consultations_screen.dart' as consult;
import 'patient_referrals_screen.dart';
import 'package:lifecare_connect/features/shared/presentation/screens/messages_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PatientDashboardMainView();
  }
}

class PatientDashboardMainView extends StatefulWidget {
  const PatientDashboardMainView({Key? key}) : super(key: key);

  @override
  State<PatientDashboardMainView> createState() => _PatientDashboardMainViewState();
}

class _PatientDashboardMainViewState extends State<PatientDashboardMainView> {
  bool _showChatBadge = false;
  bool _showAppointmentBadge = false;

  List<Map<String, dynamic>> get dashboardItems => [
    {
      'icon': Icons.health_and_safety,
      'label': 'My Health',
      'action': 'health',
      'color': Colors.red,
    },
    {
      'icon': Icons.calendar_today,
      'label': 'Appointments',
      'action': 'appointments',
      'color': Colors.blue,
      'showBadge': _showAppointmentBadge,
    },
    {
      'icon': Icons.medical_services,
      'label': 'Consultations',
      'action': 'consultations',
      'color': Colors.teal,
    },
    {
      'icon': Icons.school,
      'label': 'Education',
      'action': 'education',
      'color': Colors.orange,
    },
    {
      'icon': Icons.message,
      'label': 'Messages',
      'action': 'messages',
      'color': Colors.teal,
      'showBadge': _showChatBadge,
    },
    {
      'icon': Icons.account_balance_wallet,
      'label': 'Wallet',
      'action': 'wallet',
      'color': Colors.amber,
    },
    // AI Chatbot icon removed
  ];

  void _handleDashboardItemTap(BuildContext context, String action) {
    switch (action) {
      case 'health':
        final currentUser = FirebaseAuth.instance.currentUser;
        final patientId = currentUser?.uid ?? '';
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHealthTab(patientId: patientId)));
        break;
      case 'appointments':
        setState(() => _showAppointmentBadge = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientAppointmentsScreen()));
        break;
      case 'consultations':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const consult.PatientConsultationsScreen()));
        break;
      case 'referrals':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientReferralsScreen()));
        break;
      case 'education':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientEducationScreen()));
        break;
      case 'messages':
        setState(() => _showChatBadge = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessagesScreen()));
        break;
      case 'wallet':
        _showComingSoonDialog(context, 'Wallet');
        break;
      case 'chatbot':
        _showComingSoonDialog(context, 'AI Chatbot');
        break;
      default:
        _showComingSoonDialog(context, 'Feature');
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upcoming, color: Colors.green.shade600),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$feature feature is under development and will be available in a future update.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Stay tuned for updates!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.green.shade600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientProfileScreen()));
            },
            icon: const Icon(Icons.person),
            tooltip: "Profile",
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientSettingsScreen()));
            },
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Confirm Logout'),
                    ],
                  ),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              // Ensure dialog is closed before signOut and navigation
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  // Use GoRouter for navigation to login
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to LifeCare Connect!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access your health services and stay connected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: dashboardItems.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final item = dashboardItems[idx];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: (item['color'] as Color).withOpacity(0.18),
                            child: Icon(
                              item['icon'],
                              color: item['color'],
                              size: 32,
                            ),
                          ),
                          if (item['showBadge'] == true)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        item['label'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        final action = item['action'];
                        if (action != null && action is String) {
                          _handleDashboardItemTap(context, action);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

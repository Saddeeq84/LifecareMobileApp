// lib/screens/facility/facility_dashboard.dart

// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'facility_profile_screen.dart';
import 'facility_settings_screen.dart';
import 'facility_booking_screen.dart';
import 'facility_messages_screen.dart';
import 'facility_patient_list_screen.dart';
import 'facility_analytics_screen.dart';
import 'facility_services_screen.dart';

class FacilityDashboard extends StatelessWidget {
  const FacilityDashboard({super.key});

  // Define a list of dashboard items with icon, label, and navigation function
  List<Map<String, dynamic>> get dashboardItems => [
        {
          "icon": Icons.calendar_today,
          "label": "Bookings",
          "action": "bookings"
        },
        {
          "icon": Icons.chat,
          "label": "Messages",
          "action": "messages"
        },
        {
          "icon": Icons.people,
          "label": "My Patients",
          "action": "patients"
        },
        {
          "icon": Icons.medical_services,
          "label": "Services",
          "action": "services"
        },
        {
          "icon": Icons.analytics,
          "label": "Reports & Analytics",
          "action": "analytics"
        },
        {
          "icon": Icons.account_balance_wallet,
          "label": "Wallet",
          "action": "wallet"
        },
      ];

  // Handle logout using Firebase Auth with confirmation dialog
  Future<void> _handleLogout(BuildContext context) async {
    _showLogoutDialog(context);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout failed: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToProfile(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityProfileScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToSettings(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilitySettingsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToBookings(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityBookingScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToMessages(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityMessagesScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening messages: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToPatients(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityPatientListScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening patient list: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAnalytics(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityAnalyticsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening analytics: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToServices(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacilityServicesScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDashboardItemTap(BuildContext context, String action) {
    switch (action) {
      case 'bookings':
        _navigateToBookings(context);
        break;
      case 'messages':
        _navigateToMessages(context);
        break;
      case 'patients':
        _navigateToPatients(context);
        break;
      case 'analytics':
        _navigateToAnalytics(context);
        break;
      case 'services':
        _navigateToServices(context);
        break;
      case 'wallet':
        _showComingSoonDialog(context, 'Wallet');
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
            Icon(Icons.upcoming, color: Colors.teal),
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
            child: Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facility Dashboard"),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Profile button
          IconButton(
            onPressed: () => _navigateToProfile(context),
            icon: const Icon(Icons.person),
            tooltip: "Profile",
          ),
          // Settings button
          IconButton(
            onPressed: () => _navigateToSettings(context),
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
          // Logout button
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: dashboardItems.map((item) {
          return InkWell(
            onTap: () => _handleDashboardItemTap(context, item['action']),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      item["icon"],
                      size: 32,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item["label"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
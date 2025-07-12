import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chwScreen/chw_my_patients_screen.dart';
import '../chat_chw_side_screen.dart';

/// CHW Dashboard Screen showing tiles for features like messages, patients, reports etc.
/// One tile (Messages) shows a live unread message badge using Firestore.
class CHWDashboard extends StatefulWidget {
  const CHWDashboard({super.key});

  @override
  State<CHWDashboard> createState() => _CHWDashboardState();
}

class _CHWDashboardState extends State<CHWDashboard> {
  // Get currently logged-in CHW's ID from Firebase Authentication
  final String chwId = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Handle logout by showing a SnackBar and redirecting to login
  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully (simulated)')),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  /// Navigate to different screens based on route.
  /// Some screens require manual navigation (My Patients, Chat)
  void _onTileTap(DashboardItem item) {
    if (item.route == '/chw_my_patients') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CHWMyPatientsScreen()),
      );
    } else if (item.route == '/chat_selection') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatCHWSideScreen()),
      );
    } else {
      Navigator.pushNamed(context, item.route);
    }
  }

  /// Get live unread message count from Firestore for the current CHW
  Stream<int> getUnreadMessageCount(String chwId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: chwId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
          // Define dashboard grid layout: 2 columns
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            final item = _dashboardItems[index];

            // For Messages tile only, show live unread count using StreamBuilder
            if (item.route == '/chw_messages') {
              return StreamBuilder<int>(
                stream: getUnreadMessageCount(chwId),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return DashboardTile(
                    icon: item.icon,
                    label: item.label,
                    onTap: () => _onTileTap(item),
                    badgeCount: count,
                  );
                },
              );
            } else {
              // All other tiles use normal DashboardTile
              return DashboardTile(
                icon: item.icon,
                label: item.label,
                onTap: () => _onTileTap(item),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Custom dashboard tile with optional badge
class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
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
        child: Stack(
          children: [
            // Main content: icon and label
            Column(
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

            // Badge for unread count (if any)
            if (badgeCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Represents a single dashboard item
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

/// List of all dashboard tiles
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

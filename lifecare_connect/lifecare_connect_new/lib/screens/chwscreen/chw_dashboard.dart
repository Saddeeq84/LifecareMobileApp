import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'chw_my_patients.dart';
import 'chat_chw_side_screen.dart';
import 'chw_settings_screen.dart';
import '../../services/notification_service.dart';

class CHWDashboard extends StatefulWidget {
  const CHWDashboard({super.key});

  @override
  State<CHWDashboard> createState() => _CHWDashboardState();
}

class _CHWDashboardState extends State<CHWDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String chwId;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    chwId = user?.uid ?? '';
    _initializeLocalNotifications();

    if (chwId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    } else {
      checkForUpcomingVisits();
      _initializeFCM();
    }
  }

  void _initializeLocalNotifications() {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  @override
  Widget build(BuildContext context) {
    if (chwId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWide ? _buildGridLayout() : _buildListLayout(),
      ),
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20,
      ),
      itemCount: _dashboardItems.length,
      itemBuilder: (context, index) {
        final item = _dashboardItems[index];
        return _buildDashboardTile(item);
      },
    );
  }

  Widget _buildListLayout() {
    return ListView.separated(
      itemCount: _dashboardItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _dashboardItems[index];
        return _buildDashboardTile(item, isList: true);
      },
    );
  }

  Widget _buildDashboardTile(DashboardItem item, {bool isList = false}) {
    final tile = item.route == '/chw_messages'
        ? StreamBuilder<int>(
            stream: getUnreadMessageCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return DashboardTile(
                icon: item.icon,
                label: item.label,
                onTap: () => _onTileTap(item),
                badgeCount: count,
                isList: isList,
              );
            },
          )
        : DashboardTile(
            icon: item.icon,
            label: item.label,
            onTap: () => _onTileTap(item),
            isList: isList,
          );
    return tile;
  }

  void _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final fcmToken = await messaging.getToken();
    debugPrint("📬 FCM Token: $fcmToken");

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  void _onTileTap(DashboardItem item) {
    switch (item.route) {
      case '/chw_my_patients':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CHWMyPatientsScreen()));
        break;
      case '/chat_selection':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatCHWSideScreen()));
        break;
      case '/chw_account_settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CHWSettingsScreen()));
        break;
      default:
        Navigator.pushNamed(context, item.route);
    }
  }

  Stream<int> getUnreadMessageCount() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: chwId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> checkForUpcomingVisits() async {
    final today = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('anc_visits')
        .where('nextVisitDate', isLessThanOrEqualTo: Timestamp.fromDate(today))
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final nextVisitDate = (data['nextVisitDate'] as Timestamp?)?.toDate();
      final patientRef = doc.reference.parent.parent;

      if (nextVisitDate != null && patientRef != null) {
        final patientSnapshot = await patientRef.get();
        final patientName = patientSnapshot['name'] ?? 'Unknown Patient';

        final formattedDate = "${nextVisitDate.toLocal()}".split(' ')[0];
        await NotificationService.showInstantNotification(
          id: doc.hashCode,
          title: "📅 Visit Reminder",
          body: "$patientName has a visit scheduled for $formattedDate.",
        );
      }
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Logout"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _auth.signOut();
        context.go('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isList;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
    this.isList = false,
  });

  @override
  Widget build(BuildContext context) {
    final tileContent = ListTile(
      leading: Stack(
        children: [
          Icon(icon, size: 36, color: Colors.teal.shade800),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );

    return isList
        ? Card(child: tileContent)
        : GestureDetector(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: Colors.teal.shade800),
                      const SizedBox(height: 10),
                      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
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
                        child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
  DashboardItem(icon: Icons.settings, label: 'Settings', route: '/chw_account_settings'),
];

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    chwId = user?.uid ?? '';
    _initializeLocalNotifications();
    if (chwId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      checkForUpcomingVisits();
      _initializeFCM();
    }
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    if (chwId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            final item = _dashboardItems[index];
            if (item.route == '/chw_messages') {
              return StreamBuilder<int>(
                stream: getUnreadMessageCount(),
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
            }
            return DashboardTile(
              icon: item.icon,
              label: item.label,
              onTap: () => _onTileTap(item),
            );
          },
        ),
      ),
    );
  }

  void _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await messaging.getToken();
      debugPrint("\uD83D\uDCEC FCM Token: $fcmToken");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
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

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
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
          title: "\uD83D\uDCC5 Visit Reminder",
          body: "$patientName has a visit scheduled for $formattedDate.",
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
                    color: Colors.red, borderRadius: BorderRadius.circular(10),
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
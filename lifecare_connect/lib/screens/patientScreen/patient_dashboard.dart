import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'patient_appointment_screen.dart';
import 'patient_education_screen.dart';
import 'daily_health_tips_screen.dart';
import 'patient_profile_screen.dart';
import 'my_health_tab.dart';
import 'patient_services_tab.dart';
import '../adminScreen/admin_facilities_screen.dart';
import 'chat_chw_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  static void _enableFirestoreCache() {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  }

  Future<String?> _getUserRole(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('user_role');
    if (cached != null) return cached;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final role = doc.data()?['role'] as String?;
    if (role != null) await prefs.setString('user_role', role);
    return role;
  }

  void _navigateByRole(BuildContext ctx, String role) {
    if (role == 'patient') {
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const PatientDashboardMainView()));
    } else if (role == 'doctor') {
      Navigator.pushReplacementNamed(ctx, '/doctor_dashboard');
    } else if (role == 'admin') {
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const AdminFacilitiesScreen()));
    } else {
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const ErrorScreen(message: 'Unknown role')));
    }
  }

  @override
  Widget build(BuildContext ctx) {
    _enableFirestoreCache();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, au) {
        if (au.connectionState == ConnectionState.waiting) {
          return const SplashScreen(message: 'Checking authentication...');
        }
        final user = au.data;
        if (user == null) {
          Future.microtask(() => Navigator.pushReplacementNamed(ctx, '/login'));
          return const SplashScreen(message: 'Redirecting to login...');
        }
        return FutureBuilder<String?>(
          future: _getUserRole(user),
          builder: (ctx, rt) {
            if (rt.connectionState == ConnectionState.waiting) {
              return const SplashScreen(message: 'Verifying user role...');
            }
            if (rt.hasError || rt.data == null) {
              return const ErrorScreen(message: 'Failed to determine user role.');
            }
            Future.microtask(() => _navigateByRole(ctx, rt.data!));
            return const SplashScreen(message: 'Redirecting based on role...');
          },
        );
      },
    );
  }
}

class PatientDashboardMainView extends StatefulWidget {
  const PatientDashboardMainView({super.key});
  @override
  State<PatientDashboardMainView> createState() => _PatientDashboardMainViewState();
}

class _PatientDashboardMainViewState extends State<PatientDashboardMainView> {
  int _currentIndex = 0;
  bool _showChatBadge = false;
  bool _showAppointmentBadge = false;
  String? _userRole;
  String? _patientUid;
  String? _chatId;

  late final Stream<DocumentSnapshot>? _chatStream;
  late final Stream<QuerySnapshot>? _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _showOnboarding();
    _initializeUserData();
  }

  Future<void> _showOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('has_seen_patient_onboarding') ?? false)) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Welcome to LifeCare Connect!'),
          content: const Text(
              'You can now book appointments, access education, services, and chat with CHWs.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!')),
          ],
        ),
      );
      await prefs.setBool('has_seen_patient_onboarding', true);
    }
  }

  Future<void> _initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _userRole = prefs.getString('user_role');
      _patientUid = user.uid;
      _chatId = user.uid;
    });

    _chatStream = FirebaseFirestore.instance.collection('chats').doc(_chatId).snapshots();
    _appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: _patientUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    _chatStream!.listen((snap) {
      if (!mounted) return;
      final data = snap.data() as Map<String, dynamic>?;

      final participantsReadRaw = data?['participantsRead'];
      final participantsRead = participantsReadRaw is Map<String, dynamic>
          ? participantsReadRaw
          : <String, dynamic>{};

      final hasUnread = (_patientUid != null)
          ? (participantsRead[_patientUid] == false)
          : false;

      setState(() => _showChatBadge = hasUnread);
    });

    _appointmentsStream!.listen((snap) {
      if (!mounted) return;
      final hasPending = snap.docs.isNotEmpty;
      setState(() => _showAppointmentBadge = hasPending);
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await FirebaseAuth.instance.signOut();
  }

  List<_DashboardPage> get _pages => [
        const _DashboardPage(
          title: 'My Health',
          icon: Icons.health_and_safety_outlined,
          content: MyHealthTab(),
        ),
        const _DashboardPage(
          title: 'Appointments',
          icon: Icons.calendar_today_outlined,
          content: PatientAppointmentsScreen(),
        ),
        const _DashboardPage(
          title: 'Education',
          icon: Icons.school_outlined,
          content: PatientEducationScreen(),
        ),
        const _DashboardPage(
          title: 'Daily Tips',
          icon: Icons.tips_and_updates_outlined,
          content: DailyHealthTipsScreen(),
        ),
        const _DashboardPage(
          title: 'Services',
          icon: Icons.medical_services_outlined,
          content: PatientServicesTab(),
        ),
        _DashboardPage(
          title: 'Chat',
          icon: Icons.chat_outlined,
          content: (_chatId == null || _patientUid == null)
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<DocumentSnapshot>(
                  stream: _chatStream,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snap.hasData || !snap.data!.exists) {
                      return ListTile(
                        leading: const Icon(Icons.chat),
                        title: const Text('Chat'),
                        subtitle: const Text('Start chat'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatCHWScreen()),
                        ),
                      );
                    }

                    final data = snap.data!.data() as Map<String, dynamic>;
                    final lastMsg = data['lastMessage'] ?? 'Start chat';
                    final hasUnread = (data['participantsRead']?[_patientUid] ?? true) == false;

                    return ListTile(
                      leading: Stack(
                        children: [
                          const Icon(Icons.chat),
                          if (hasUnread)
                            const Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                            ),
                        ],
                      ),
                      title: const Text('Chat'),
                      subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatCHWScreen()),
                      ),
                    );
                  },
                ),
        ),
        const _DashboardPage(
          title: 'Profile',
          icon: Icons.person_outline,
          content: PatientProfileScreen(),
        ),
        const _DashboardPage(
          title: 'Settings',
          icon: Icons.settings_outlined,
          content: Center(child: Text("Settings (UI only)")),
        ),
      ];

  @override
  Widget build(BuildContext ctx) {
    final page = _pages[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(page.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        actions: [
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AdminFacilitiesScreen()));
              },
            ),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: page.content),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
            if (i == 1) _showAppointmentBadge = false;
            if (i == 6) _showChatBadge = false;
          });
        },
        items: [
          for (int i = 0; i < _pages.length; i++)
            BottomNavigationBarItem(icon: _buildBadgeIcon(i), label: _pages[i].title),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(int i) {
    final icon = Icon(_pages[i].icon);
    final shouldBadge = (i == 1 && _showAppointmentBadge) || (i == 6 && _showChatBadge);
    return shouldBadge
        ? Stack(clipBehavior: Clip.none, children: [
            icon,
            const Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: Colors.red)),
          ])
        : icon;
  }
}

class _DashboardPage {
  final String title;
  final IconData icon;
  final Widget content;
  const _DashboardPage({required this.title, required this.icon, required this.content});
}

class SplashScreen extends StatelessWidget {
  final String message;
  const SplashScreen({super.key, required this.message});
  @override
  Widget build(BuildContext ctx) => Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ]),
        ),
      );
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});
  @override
  Widget build(BuildContext ctx) =>
      Scaffold(body: Center(child: Text(message, style: const TextStyle(fontSize: 16, color: Colors.red))));
}

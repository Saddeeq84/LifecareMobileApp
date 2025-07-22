// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/user_service.dart';

// Admin Screens
import 'screens/auth/login_screen.dart';
import 'screens/adminscreen/admin_dashboard.dart';
import 'screens/doctorscreen/doctor_facility_referral_screen.dart';
import 'screens/adminscreen/approvals_screen.dart';
import 'screens/adminscreen/approve_doctors_screen.dart';
import 'screens/adminscreen/approve_facilities_screen.dart';
import 'screens/adminscreen/admin_patient_list_screen.dart';
import 'screens/adminscreen/admin_facility_list_screen.dart';
import 'screens/adminscreen/admin_staff_screen.dart';
import 'screens/adminscreen/admin_register_facility_screen.dart';
import 'screens/adminscreen/admin_appointment_screen.dart';
import 'screens/adminscreen/referrals_screen.dart';
import 'screens/adminscreen/admin_training_upload_screen.dart';
import 'screens/adminscreen/admin_settings_screen.dart';
import 'screens/adminscreen/admin_analytics_screen.dart';

// Doctor Screens
import 'screens/doctorscreen/doctor_dashboard.dart';
import 'screens/doctorscreen/doctor_consultation_screen.dart';

// CHW Screens
import 'screens/chwscreen/chw_dashboard.dart';
import 'screens/chwscreen/patient_registration_screen.dart'; // This is the wrapper screen
import 'screens/chwscreen/anc_checklist_screen.dart';
import 'screens/chwscreen/patient_list_screen.dart';
import 'screens/chwscreen/chw_appointments_screen.dart';
import 'screens/chwscreen/referrals_screen.dart';
import 'screens/chwscreen/chw_consultation_screen.dart';
import 'screens/chwscreen/chw_messages_screen.dart';
import 'screens/chwscreen/chw_profile_screen.dart';
import 'screens/chwscreen/chw_settings_screen.dart';

// Patient Screens
import 'screens/patientscreen/patient_dashboard.dart';

// Facility Screens
import 'screens/facilityscreen/facility_dashboard.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FirebaseAuth _auth = FirebaseAuth.instance;
final UserService _userService = UserService();

/// Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _safeFirebaseInit();
  print('📩 Background message: ${message.messageId}');
}

Future<void> _safeFirebaseInit() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

Future<void> initializeFirebase() async {
  await _safeFirebaseInit();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider('your-key-here'),
    );
    print("✅ Firebase App Check activated");
  } catch (e) {
    print("🔥 App Check activation failed: $e");
  }

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }
}

/// 🟢 Main Entry Point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  if (_auth.currentUser != null) {
    await _userService.fetchUserRole();
  }

  final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: AuthNotifier(),
    redirect: (context, state) async {
      final user = _auth.currentUser;
      final location = state.uri.toString();
      final role = _userService.cachedUserRole;

      print("🔄 Redirect called. Location: $location, User: $user, Role: $role");

      // If no user, redirect to login (except if already on login)
      if (user == null) {
        return location == '/login' ? null : '/login';
      }

      // If user exists but no role cached, try to fetch it
      if (role == null) {
        try {
          await _userService.fetchUserRole();
          final newRole = _userService.cachedUserRole;
          if (newRole == null) {
            // If still no role after fetching, go to login
            return '/login';
          }
        } catch (e) {
          print("Error fetching user role: $e");
          return '/login';
        }
      }

      // Redirect from initial routes to appropriate dashboard
      if (location == '/login' || location == '/loading' || location == '/') {
        final currentRole = _userService.cachedUserRole;
        switch (currentRole) {
          case 'admin':
            return '/admin_dashboard';
          case 'patient':
            return '/patient_dashboard';
          case 'doctor':
            return '/doctor_dashboard';
          case 'chw':
            return '/chw_dashboard';
          case 'facility':
            return '/facility_dashboard';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/loading', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/admin_dashboard', builder: (context, state) => const AdminDashboard()),

      // Admin
      GoRoute(path: '/admin/approvals_screen', builder: (context, state) => const ApprovalsScreen()),
      GoRoute(path: '/admin/approve_doctors', builder: (context, state) => const ApproveDoctorsScreen()),
      GoRoute(path: '/admin/approve_facilities', builder: (context, state) => const ApproveFacilitiesScreen()),
      GoRoute(path: '/admin/patient_list', builder: (context, state) => AdminPatientListScreen()),
      GoRoute(path: '/admin/facility', builder: (context, state) => const AdminFacilityListScreen()),
      GoRoute(path: '/admin/staff', builder: (context, state) => const AdminStaffScreen()),
      GoRoute(path: '/admin/appointments', builder: (context, state) => const AdminAppointmentScreen()),
      GoRoute(path: '/admin/referrals', builder: (context, state) => const ReferralsScreen()),
      GoRoute(path: '/admin/upload_training', builder: (context, state) => const AdminTrainingUploadScreen()),
      GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/analytics', builder: (context, state) => const AdminAnalyticsScreen()),

      // CHW
      GoRoute(path: '/register_patient', builder: (context, state) => const PatientRegistrationScreen(isCHW: false)),
      GoRoute(path: '/chw/register_patient', builder: (context, state) => const PatientRegistrationScreen(isCHW: true)),
      GoRoute(path: '/my_patients', builder: (context, state) => const ChwPatientListScreen()),
      GoRoute(path: '/chw_appointments', builder: (context, state) => const CHWAppointmentsScreen()),
      GoRoute(path: '/chw_consultation', builder: (context, state) {
        print('🎯 CHW Consultation route accessed!');
        return const CHWConsultationScreen();
      }),
      GoRoute(path: '/messages', builder: (context, state) => const CHWMessagesScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const CHWProfileScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const CHWSettingsScreen()),
      GoRoute(path: '/chw_test', builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('CHW Test Route')),
        body: const Center(child: Text('CHW Test Route Works!', style: TextStyle(fontSize: 24))),
      )),
      GoRoute(path: '/referrals', builder: (context, state) => const ReferralScreen()),
      GoRoute(path: '/anc_checklist', builder: (context, state) {
        print('🎯 ANC Checklist route accessed!');
        return const ANCChecklistScreen();
      }),
      GoRoute(path: '/test', builder: (context, state) => const Scaffold(
        body: Center(child: Text('Test Route Works!', style: TextStyle(fontSize: 24))),
      )),

      // Shared
      GoRoute(path: '/register_facility', name: 'register_facility', builder: (context, state) => const AdminRegisterFacilityScreen()),

      // Dashboards
      GoRoute(path: '/chw_dashboard', builder: (context, state) => const CHWDashboard()),
      GoRoute(path: '/doctor_dashboard', builder: (context, state) => const DoctorDashboard()),
      GoRoute(path: '/patient_dashboard', builder: (context, state) => const PatientDashboard()),
      GoRoute(path: '/facility_dashboard', builder: (context, state) => const FacilityDashboard()),

      // Doctor Extras
      GoRoute(path: '/doctor/facility_referral', builder: (context, state) => const DoctorFacilityReferralScreen()),
      GoRoute(path: '/consultation', builder: (context, state) => const DoctorConsultationScreen()),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text("❌ 404 - Page Not Found", style: TextStyle(fontSize: 20)),
      ),
    ),
  );

  runApp(LifeCareApp(router: router));
}

class LifeCareApp extends StatelessWidget {
  final GoRouter router;
  const LifeCareApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeCare Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'OpenSans',
      ),
      routerConfig: router,
    );
  }
}

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

// ✅ Screens
import 'screens/adminscreen/admin_staff_screen.dart';
import 'screens/chwscreen/chw_refer_patient_screen.dart';
import 'screens/adminscreen/admin_dashboard.dart';
import 'screens/adminscreen/approval_screen.dart';
import 'screens/adminscreen/admin_doctor_list_screen.dart';
import 'screens/adminscreen/admin_analytics_screen.dart';
import 'screens/adminscreen/admin_upload_training_screen.dart';
import 'screens/adminscreen/all_appointments_screen.dart';
import 'screens/adminscreen/admin_register_facility_screen.dart';
import 'screens/adminscreen/admin_messages_screen.dart';
import 'screens/adminscreen/referrals_screen.dart';
import 'screens/adminscreen/admin_settings_screen.dart';
import 'screens/sharedscreen/patient_list_widget.dart';
import 'screens/patientscreen/patient_book_doctor_screen.dart';
import 'screens/adminscreen/admin_chw_list_screen.dart';
import 'screens/patientscreen/patient_book_chw_screen.dart';
import 'screens/adminscreen/admin_facility_list_screen.dart';
import 'screens/chwscreen/chw_refer_to_facility_screen.dart';
import 'screens/patientscreen/patient_book_facility_screen.dart';
import 'screens/doctorscreen/doctor_facility_referral_screen.dart';
import 'screens/doctorscreen/doctor_chw_chat_screen.dart';
import 'screens/auth/login_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Firestore offline support
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // ✅ Firebase App Check
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider('6LffLoErAAAAAMH-nYVE9rLDo17DdQDyj9V9yJei'), // Update for your domain
    );
    print("✅ Firebase App Check activated");
  } catch (e) {
    print("🔥 Firebase App Check activation failed: $e");
  }

  // ✅ Local Notifications Setup
  const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return MaterialApp.router(
          title: 'LifeCare Connect',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.teal),
          routerConfig: _router,
        );
      },
    );
  }
}

// ✅ Routing Setup
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text("404 - Page Not Found", style: TextStyle(fontSize: 20))),
  ),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Admin
    GoRoute(path: '/admin_dashboard', builder: (context, state) => const AdminDashboard()),
    GoRoute(path: '/admin/approve_accounts', builder: (context, state) => const ApprovalScreen()),
    GoRoute(path: '/admin/staff_list', builder: (context, state) => const AdminStaffScreen()),
    GoRoute(path: '/admin/patient_list', builder: (context, state) => PatientListScreen(
      userRole: 'admin', onPatientTap: (patient) {}),
    ),
    GoRoute(path: '/admin/analytics', builder: (context, state) => const AdminAnalyticsScreen()),
    GoRoute(path: '/admin/upload_training', builder: (context, state) => const AdminUploadTrainingScreen()),
    GoRoute(path: '/admin/all_appointments', builder: (context, state) => const AdminAllAppointmentsScreen()),
    GoRoute(path: '/admin/register_facility', builder: (context, state) => const AdminRegisterFacilityScreen()),
    GoRoute(path: '/admin/messages', builder: (context, state) => const AdminMessagesScreen()),
    GoRoute(path: '/admin/referrals', builder: (context, state) => const ReferralsScreen()),
    GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),
    GoRoute(path: '/admin/doctor_list', builder: (context, state) => const AdminDoctorListScreen()),
    GoRoute(path: '/admin/chw_list', builder: (context, state) => const AdminCHWListScreen()),
    GoRoute(path: '/admin/facilities', builder: (context, state) => const AdminFacilityListScreen()),

    // CHW
    GoRoute(path: '/chw/refer_doctor', builder: (context, state) => const CHWReferPatientScreen()),
    GoRoute(path: '/chw/refer_facility', builder: (context, state) => const CHWReferToFacilityScreen()),

    // Patient
    GoRoute(path: '/patient/book_doctor', builder: (context, state) => const PatientBookDoctorScreen()),
    GoRoute(path: '/patient/book_chw', builder: (context, state) => const PatientBookCHWScreen()),
    GoRoute(path: '/patient/book_facility', builder: (context, state) => const PatientBookFacilityScreen()),

    // Doctor
    GoRoute(path: '/doctor/chw_chat', builder: (context, state) => const DoctorCHWChatScreen()),
    GoRoute(path: '/doctor/facility_referral', builder: (context, state) => const DoctorFacilityReferralScreen()),
  ],
);

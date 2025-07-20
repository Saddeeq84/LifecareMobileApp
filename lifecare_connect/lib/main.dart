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

// Screens
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FirebaseAuth _auth = FirebaseAuth.instance;
final UserService _userService = UserService();

/// 🔁 Background notification handler
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
      webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_KEY'),
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

/// 🔁 Helper to refresh GoRouter on auth or role changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners(), onError: (e) {
      print("⚠️ GoRouter stream error: $e");
    });
  }
}

/// ✅ Combines auth and role stream
Stream<dynamic> get combinedRefreshStream =>
    _auth.authStateChanges().asyncExpand((user) async* {
      await _userService.fetchUserRole(); // Update cached role
      yield user;
    });

/// ⏳ Splash screen while redirecting
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ✅ Route Constants
const String loginRoute = '/login';
const String loadingRoute = '/loading';
const String adminDashboardRoute = '/admin_dashboard';
const String staffListRoute = '/admin/staff';

/// 🧭 App Router
final GoRouter _router = GoRouter(
  initialLocation: loadingRoute,
  refreshListenable: GoRouterRefreshStream(combinedRefreshStream),
  redirect: (context, state) {
    final user = _auth.currentUser;
    final location = state.uri.toString();
    print("🔄 Redirect called. Location: $location, User: $user");

    if (user == null) {
      return location == loginRoute ? null : loginRoute;
    }

    final role = _userService.cachedUserRole;
    print("🎯 Cached User Role: $role");

    if (role == null) {
      return location != loadingRoute ? loadingRoute : null;
    }

    if (location == loadingRoute || location == loginRoute) {
      switch (role) {
        case 'admin':
          return adminDashboardRoute;
        case 'patient':
          return '/patient/book_doctor';
        case 'doctor':
          return '/doctor/facility_referral';
        case 'chw':
          return '/chw/refer_doctor';
        default:
          return loginRoute;
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: loadingRoute, builder: (context, state) => const SplashScreen()),
    GoRoute(path: loginRoute, builder: (context, state) => const LoginScreen()),
    GoRoute(path: adminDashboardRoute, builder: (context, state) => const AdminDashboard()),

    // ✅ Admin routes
    GoRoute(path: '/admin/approvals_screen', builder: (context, state) => const ApprovalsScreen()),
    GoRoute(path: '/admin/approve_doctors', builder: (context, state) => const ApproveDoctorsScreen()),
    GoRoute(path: '/admin/approve_facilities', builder: (context, state) => const ApproveFacilitiesScreen()),
    GoRoute(path: '/admin/patient_list', builder: (context, state) => AdminPatientListScreen()),
    GoRoute(path: '/admin/facility', builder: (context, state) => const AdminFacilityListScreen()),
    GoRoute(path: staffListRoute, builder: (context, state) => const AdminStaffScreen()),
    GoRoute(path: '/admin/appointments', builder: (context, state) => const AdminAppointmentScreen()),
    GoRoute(path: '/admin/referrals', builder: (context, state) => const ReferralsScreen()),
    GoRoute(path: '/admin/upload_training', builder: (context, state) => const AdminTrainingUploadScreen()),
    GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),

    // ✅ Shared: Register facility (for both admin and individual users)
    GoRoute(path: '/register_facility',name: 'register_facility',builder: (context, state) => const AdminRegisterFacilityScreen()),

    // ✅ Role-based route
    GoRoute(path: '/doctor/facility_referral', builder: (context, state) => const DoctorFacilityReferralScreen()),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text("❌ 404 - Page Not Found", style: TextStyle(fontSize: 20)),
    ),
  ),
);

/// 🌍 App Entry Widget
class LifeCareApp extends StatelessWidget {
  const LifeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeCare Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'OpenSans',
      ),
      routerConfig: _router,
    );
  }
}

/// ✅ Main Entry Point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const LifeCareApp());
}

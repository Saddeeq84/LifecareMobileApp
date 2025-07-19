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
import 'screens/patientscreen/patient_book_doctor_screen.dart';
import 'screens/doctorscreen/doctor_facility_referral_screen.dart';
import 'screens/chwscreen/chw_refer_patient_screen.dart';
import 'screens/adminscreen/approvals_screen.dart';
import 'screens/adminscreen/approve_doctors_screen.dart';
import 'screens/adminscreen/approve_facilities_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FirebaseAuth _auth = FirebaseAuth.instance;
final UserService _userService = UserService();

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

/// 🔁 Helper to refresh GoRouter on auth state changes and user role changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}

// We create a combined Stream to refresh router on both auth and role changes
Stream<dynamic> get combinedRefreshStream async* {
  await for (final event in _auth.authStateChanges()) {
    // Wait a bit to ensure user role is cached
    await _userService.fetchUserRole();
    yield event;
  }
}

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const LifeCareApp());
}

/// 🧭 Define the router globally for stable redirection
final GoRouter _router = GoRouter(
  initialLocation: '/loading',
  refreshListenable: GoRouterRefreshStream(combinedRefreshStream),
  redirect: (context, state) {
    final user = _auth.currentUser;
    final location = state.uri.toString();
    print("🔄 Redirect called. Location: $location, User: $user");

    // Not logged in
    if (user == null) {
      return location == '/login' ? null : '/login';
    }

    // User is logged in, check cached role (synchronous)
    final role = _userService.cachedUserRole;
    print("🎯 Cached User Role: $role");

    // If role not yet cached, show loading screen
    if (role == null) {
      // Avoid redirect loop by returning null (show current page - /loading)
      if (location != '/loading') {
        return '/loading';
      }
      return null;
    }

    // From loading or login, route user to dashboard based on role
    if (location == '/loading' || location == '/login') {
      switch (role) {
        case 'admin':
          return '/admin_dashboard';
        case 'patient':
          return '/patient/book_doctor';
        case 'doctor':
          return '/doctor/facility_referral';
        case 'chw':
          return '/chw/refer_doctor';
        default:
          return '/login'; // fallback for unknown roles
      }
    }

    return null; // no redirect
  },
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin_dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/approval_screen',
      builder: (context, state) => const ApprovalsScreen(),
    ),
    GoRoute(
      path: '/patient/book_doctor',
      builder: (context, state) => const PatientBookDoctorScreen(),
    ),
    GoRoute(
      path: '/doctor/facility_referral',
      builder: (context, state) => const DoctorFacilityReferralScreen(),
    ),
    GoRoute(
      path: '/chw/refer_doctor',
      builder: (context, state) => const CHWReferPatientScreen(),
    ),
    GoRoute(
      path: '/admin/approve_doctors',
      builder: (context, state) => const ApproveDoctorsScreen(),
    ),
    GoRoute(
      path: '/admin/approve_facilities',
      builder: (context, state) => const ApproveFacilitiesScreen(),
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text("❌ 404 - Page Not Found", style: TextStyle(fontSize: 20)),
    ),
  ),
);

/// 🌍 Main App Widget using MaterialApp.router
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

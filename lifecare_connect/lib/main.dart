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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _safeFirebaseInit();
  print('📩 Background message: ${message.messageId}');
}

Future<void> _safeFirebaseInit() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(LifeCareApp());
}

class LifeCareApp extends StatefulWidget {
  const LifeCareApp({super.key});

  @override
  State<LifeCareApp> createState() => _LifeCareAppState();
}

class _LifeCareAppState extends State<LifeCareApp> {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/loading',
      refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),
      redirect: (context, state) async {
        final user = _auth.currentUser;
        final location = state.uri.toString();

        if (location == '/loading') {
          if (user == null) return '/login';

          final role = await _userService.getUserRole();
          if (role == 'admin') return '/admin_dashboard';
          if (role == 'patient') return '/patient/book_doctor';
          if (role == 'doctor') return '/doctor/facility_referral';
          if (role == 'chw') return '/chw/refer_doctor';

          return '/login'; // fallback
        }

        if (user == null && location != '/login') return '/login';
        if (user != null && location == '/login') {
          final role = await _userService.getUserRole();
          if (role == 'admin') return '/admin_dashboard';
          if (role == 'patient') return '/patient/book_doctor';
          if (role == 'doctor') return '/doctor/facility_referral';
          if (role == 'chw') return '/chw/refer_doctor';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/admin_dashboard', builder: (context, state) => const AdminDashboard()),
        GoRoute(path: '/patient/book_doctor', builder: (context, state) => const PatientBookDoctorScreen()),
        GoRoute(path: '/doctor/facility_referral', builder: (context, state) => const DoctorFacilityReferralScreen()),
        GoRoute(path: '/chw/refer_doctor', builder: (context, state) => const CHWReferPatientScreen()),
      ],
      errorBuilder: (context, state) => const Scaffold(
        body: Center(child: Text("404 - Page Not Found", style: TextStyle(fontSize: 20))),
      ),
    );
  }

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

/// 🔁 Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}

/// ⏳ Splash/loading screen while checking auth state
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

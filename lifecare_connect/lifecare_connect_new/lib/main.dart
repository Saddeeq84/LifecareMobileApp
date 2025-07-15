import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

// ✅ Screen Imports
import 'package:lifecare_connect/screens/auth/login_screen.dart';
import 'package:lifecare_connect/screens/chwscreen/chw_create_account.dart';
import 'package:lifecare_connect/screens/doctorscreen/doctor_dashboard.dart';
import 'package:lifecare_connect/screens/patientscreen/patient_dashboard.dart';
import 'package:lifecare_connect/screens/chwscreen/chw_dashboard.dart';
import 'package:lifecare_connect/screens/adminscreen/admin_dashboard.dart';
import 'package:lifecare_connect/screens/facilityscreen/facility_dashboard.dart';
import 'package:lifecare_connect/screens/sharedscreen/splash_screen.dart' as shared; // 🔄 added "as shared" to avoid conflict

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LffLoErAAAAAMH-nYVE9rLDo17DdQDyj9V9yJei'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeCare Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text("404 - Page Not Found", style: TextStyle(fontSize: 20))),
  ),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const shared.SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/chw_create_account', builder: (context, state) => const CHWCreateAccountScreen()),
    GoRoute(path: '/doctor_dashboard', builder: (context, state) => const DoctorDashboard()),
    GoRoute(path: '/patient_dashboard', builder: (context, state) => const PatientDashboard()),
    GoRoute(path: '/chw_dashboard', builder: (context, state) => const CHWDashboard()),
    GoRoute(path: '/admin_dashboard', builder: (context, state) => const AdminDashboard()),
    GoRoute(path: '/facility_dashboard', builder: (context, state) => const FacilityDashboard()),
  ],
);

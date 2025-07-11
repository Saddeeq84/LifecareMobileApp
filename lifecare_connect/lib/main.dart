// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Screens
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/chw_dashboard.dart';
import 'screens/dashboards/doctor_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/facility_dashboard.dart';
import 'screens/sharedScreen/login_page.dart';
import 'screens/admin/admin_upload_education_screen.dart'; // ✅ Imported Upload Education screen

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore cache only once (recommended location)
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: ReCaptchaV3Provider('your-public-site-key'),
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await messaging.requestPermission();
  String? fcmToken = await messaging.getToken();
  print('🔔 FCM Token: $fcmToken');

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

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
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  runApp(const LifeCareConnectApp());
}

class LifeCareConnectApp extends StatelessWidget {
  const LifeCareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeCare Connect',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AppEntryPoint(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/patient_dashboard': (context) => const PatientDashboard(),
        '/chw_dashboard': (context) => const CHWDashboard(),
        '/doctor_dashboard': (context) => const DoctorDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/admin_panel': (context) => const AdminDashboard(),
        '/facility_dashboard': (context) => const FacilityDashboard(),
        '/admin_upload_education': (context) => const AdminUploadEducationScreen(), // ✅ New route
      },
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  User? _user;
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user == null) {
      setState(() {
        _loading = false;
        _role = null;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      _role = doc.exists && doc.data()!.containsKey('role') ? doc['role'] as String : null;
    } catch (e) {
      print('Error fetching user role: $e');
      _role = null;
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null || _role == null) {
      return const LoginPage();
    }

    switch (_role!.toLowerCase()) {
      case 'patient':
        return const PatientDashboard();
      case 'doctor':
        return const DoctorDashboard();
      case 'chw':
        return const CHWDashboard();
      case 'admin':
        return const AdminDashboard();
      case 'facility':
        return const FacilityDashboard();
      default:
        return const LoginPage();
    }
  }
}

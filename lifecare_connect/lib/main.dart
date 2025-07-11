import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // 👈 App Check import
import 'firebase_options.dart';

// 📦 Dashboards
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/chw_dashboard.dart';
import 'screens/dashboards/doctor_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/facility_dashboard.dart';

// 👩‍⚕️ CHW Screens
import 'screens/chw_my_patients_screen.dart';
import 'screens/chw_profile_screen.dart';
import 'screens/chw_messages_screen.dart';
import 'screens/forms/register_new_patient.dart';
import 'screens/forms/anc_pnc_checklist.dart';
import 'screens/forms/chw_upcoming_visits.dart';
import 'screens/forms/chw_referrals.dart';
import 'screens/forms/chw_training_and_education.dart';
import 'screens/forms/chw_reports.dart';
import 'screens/forms/chw_appointments.dart';
import 'screens/forms/chats/chat_selection_screen.dart' as chat_selection;
import 'screens/forms/chats/doctor_list_screen.dart';
import 'screens/forms/chats/patient_list_screen.dart';
import 'screens/forms/chats/chw_chat_screen.dart' as chw_chat;

// 🧑‍⚕️ Patient Screens
import 'screens/appointments/patient_appointment_screen.dart';
import 'screens/appointments/book_patient_appointment_screen.dart';
import 'screens/patient_education_screen.dart';

// 👨‍⚕️ Doctor Screens
import 'screens/doctor_referrals_screen.dart';
import 'screens/doctor_patients_screen.dart';
import 'screens/doctor_scheduled_consults_screen.dart';
import 'screens/doctor_notes_screen.dart';
import 'screens/doctor_reports_screen.dart';
import 'screens/doctor_profile_screen.dart';

// 🧑‍💼 Admin Screens
import 'screens/admin_manage_users_screen.dart';
import 'screens/admin_facilities_screen.dart';
import 'screens/admin_register_facility_screen.dart';
import 'screens/admin_reports_screen.dart';
import 'screens/admin_training_screen.dart';
import 'screens/admin_messages_screen.dart';
import 'screens/admin_settings_screen.dart';

// 🏥 Facility Screens
import 'screens/facility_login_screen.dart';
import 'screens/facility_register_screen.dart';

// 🔐 Login Screen (now the entry point)
import 'screens/login_page.dart';

// 🔔 Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize Firebase App Check for Android (uses default provider)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use .playIntegrity for production
    webProvider: ReCaptchaV3Provider('your-public-site-key'), // Optional if targeting web
  );

  // ✅ Initialize local notifications
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const LifeCareConnectApp());
}

class LifeCareConnectApp extends StatelessWidget {
  const LifeCareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeCare Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LoginPage(),

      routes: {
        '/login': (context) => const LoginPage(),

        // 🧑‍⚕️ PATIENT ROUTES
        '/patient_dashboard': (context) => const PatientDashboard(),
        '/patient_appointments': (context) => const PatientAppointmentsScreen(),
        '/book_patient_appointment': (context) => const BookPatientAppointmentScreen(),
        '/patient_education': (context) => const PatientEducationScreen(),

        // 👩‍⚕️ CHW ROUTES
        '/chw_dashboard': (context) => const CHWDashboard(),
        '/chw_my_patients': (context) => CHWMyPatientsScreen(),
        '/chw_profile': (context) => const CHWProfileScreen(),
        '/chw_messages': (context) => const CHWMessagesScreen(),
        '/register_patient': (context) => const RegisterNewPatientScreen(),
        '/anc_checklist': (context) => const ANCChecklistScreen(),
        '/chw_visits': (context) => const CHWUpcomingVisitsScreen(),
        '/referrals': (context) => const CHWReferralsScreen(),
        '/training_education': (context) => const CHWTrainingAndEducationScreen(),
        '/chw_reports': (context) => const CHWReportsScreen(),
        '/chw_appointments': (context) => CHWAppointmentsScreen(
              notificationsPlugin: flutterLocalNotificationsPlugin,
            ),

        // 💬 CHW CHAT
        '/chat_selection': (context) => const chat_selection.ChatSelectionScreen(),
        '/chw_chat_doctor': (context) => const DoctorListScreen(),
        '/chw_chat_patient': (context) => const PatientListScreen(),
        '/chw_chat': (context) => const chw_chat.CHWChatScreen(
              chatId: 'default_chat',
              recipientType: 'Unknown',
              recipientName: 'Unknown',
            ),

        // 👨‍⚕️ DOCTOR ROUTES
        '/doctor_dashboard': (context) => const DoctorDashboard(),
        '/doctor_patients': (context) => const DoctorPatientsScreen(),
        '/doctor_referrals': (context) => const DoctorReferralsScreen(),
        '/doctor_profile': (context) => const DoctorProfileScreen(),
        '/doctor_schedule': (context) => const DoctorScheduledConsultsScreen(),
        '/doctor_notes': (context) => const DoctorNotesScreen(),
        '/doctor_reports': (context) => const DoctorReportsScreen(),

        // 🧑‍💼 ADMIN ROUTES
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/admin_manage_users': (context) => const AdminManageUsersScreen(),
        '/admin_facilities': (context) => const AdminFacilitiesScreen(),
        '/admin_register_facility': (context) => const RegisterFacilityScreen(),
        '/admin_reports': (context) => const AdminReportsScreen(),
        '/admin_training': (context) => const AdminTrainingScreen(),
        '/admin_messages': (context) => const AdminMessagesScreen(),
        '/admin_settings': (context) => const AdminSettingsScreen(),

        // 🏥 FACILITY ROUTES
        '/facility_login': (context) => const FacilityLoginScreen(),
        '/facility_register': (context) => const FacilityRegisterScreen(),
        '/facility_dashboard': (context) => const FacilityDashboard(),
      },
    );
  }
}

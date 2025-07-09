import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/chw_dashboard.dart';
import 'screens/dashboards/doctor_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';

// CHW Screens
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

// Patient Screens
import 'screens/appointments/patient_appointment_screen.dart';
import 'screens/appointments/book_patient_appointment_screen.dart';
import 'screens/patient_education_screen.dart';

// Doctor Screens
// import 'screens/doctor_consultation.dart';
import 'screens/doctor_referrals.dart';

// ✅ Real login screen
import 'screens/login_page.dart';

// ✅ TEMP: Add dashboard selector for UI-only testing
import 'screens/dashboard_selector_screen.dart'; // 👈 Create this file

// Define the notifications plugin globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Setup notifications (UI only)
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

      // ✅ Uncomment the next line for real login when Firebase is ready
      // initialRoute: '/login',

      // ✅ TEMP: Testing mode entry screen for Patient/CHW/Doctor/Admin
      home: const DashboardSelectorScreen(), // 👈 For UI testing only

      routes: {
        // 🔐 Login system (keep this intact for later)
        '/login': (context) => const LoginPage(),

        // 🧑‍⚕️ Patient Routes
        '/patient_dashboard': (context) => const PatientDashboard(),
        '/patient_appointments': (context) => const PatientAppointmentsScreen(),
        '/book_patient_appointment': (context) => const BookPatientAppointmentScreen(),
        '/patient_education': (context) => const PatientEducationScreen(),

        // 👩‍⚕️ CHW Routes
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

        // 💬 CHW Chat
        '/chat_selection': (context) => const chat_selection.ChatSelectionScreen(),
        '/chw_chat_doctor': (context) => const DoctorListScreen(),
        '/chw_chat_patient': (context) => const PatientListScreen(),
        '/chw_chat': (context) => const chw_chat.CHWChatScreen(
              chatId: 'default_chat',
              recipientType: 'Unknown',
              recipientName: 'Unknown',
            ),

        // 👨‍⚕️ Doctor Routes
        '/doctor_dashboard': (context) => const DoctorDashboardScreen(),
        // '/doctor_consultations': (context) => const DoctorConsultationsScreen(),
        '/doctor_referrals': (context) => const DoctorReferralsScreen(),

        // 🧑‍💼 Admin Dashboard (UI only)
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
// Note: Ensure that the recipientType and recipientName are passed correctly
// in the chat screens to avoid errors. This is a placeholder for the actual chat implementation.
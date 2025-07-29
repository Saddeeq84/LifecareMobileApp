// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'presentation/screens/profile.dart';
import 'presentation/screens/settings.dart';
import 'features/chw/presentation/screens/chw_appointments_screen.dart';
import 'presentation/screens/messages.dart';
import 'presentation/screens/patients.dart';
import 'presentation/screens/register_patient.dart';

class CHWApp extends StatelessWidget {
  const CHWApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeCare CHW',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/chw_dashboard/profile': (context) => const ProfileScreen(),
        '/chw_dashboard/settings': (context) => const SettingsScreen(),
        '/chw_dashboard/appointments': (context) => CHWAppointmentsScreen(),
        '/chw_dashboard/messages': (context) => const MessagesScreen(),
        '/chw_dashboard/patients': (context) => const PatientsScreen(),
        '/chw_dashboard/register_patient': (context) => const RegisterPatientScreen(),

      },
    );
  }
}
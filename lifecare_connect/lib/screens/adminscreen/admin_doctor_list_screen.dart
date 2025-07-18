// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../sharedscreen/doctor_list_widget.dart';

class AdminDoctorListScreen extends StatelessWidget {
  const AdminDoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Doctors')),
      body: DoctorListWidget(
        viewerRole: 'admin',
        onDoctorTap: (doctor) {
          // You can navigate to detailed admin screen if needed
          print("Admin selected doctor: ${doctor.id}");
        },
      ),
    );
  }
}

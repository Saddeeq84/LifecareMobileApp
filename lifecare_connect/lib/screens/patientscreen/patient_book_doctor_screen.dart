import 'package:flutter/material.dart';
import '../sharedscreen/doctor_list_widget.dart';

class PatientBookDoctorScreen extends StatelessWidget {
  const PatientBookDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: DoctorListWidget(
        viewerRole: 'patient',
        onDoctorTap: (doctor) {
          final name = (doctor.data() as Map<String, dynamic>)['fullName'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking appointment with Dr. $name...')),
          );
        },
      ),
    );
  }
}

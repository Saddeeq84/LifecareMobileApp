import 'package:flutter/material.dart';
import '../sharedscreen/doctor_list_widget.dart';

class CHWReferDoctorScreen extends StatelessWidget {
  const CHWReferDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer Patient to Doctor')),
      body: DoctorListWidget(
        viewerRole: 'chw',
        onDoctorTap: (doctor) {
          // Navigate to referral form or show confirmation
          final name = (doctor.data() as Map<String, dynamic>)['fullName'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral initiated to $name')),
          );
        },
      ),
    );
  }
}

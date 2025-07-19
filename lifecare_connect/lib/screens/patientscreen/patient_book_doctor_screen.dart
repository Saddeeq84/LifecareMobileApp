import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../sharedscreen/doctor_list_widget.dart';

class PatientBookDoctorScreen extends StatelessWidget {
  const PatientBookDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text("Logout"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
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

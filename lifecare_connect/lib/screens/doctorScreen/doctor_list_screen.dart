import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/chwscreen/chw_chat_screen.dart';
// Ensure that CHWChatScreen is defined as a class in chw_chat_screen.dart and exported properly.

final List<Map<String, String>> registeredDoctors = [
  {'id': 'd1', 'name': 'Dr. James'},
  {'id': 'd2', 'name': 'Dr. Amina'},
];

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered Doctors'), backgroundColor: Colors.teal),
      body: ListView.builder(
        itemCount: registeredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = registeredDoctors[index];
          return ListTile(
            title: Text(doctor['name']!),
            leading: const Icon(Icons.local_hospital),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CHWChatScreen(
                    chatId: 'doctor_chat_${doctor['id']}',
                    recipientType: 'Doctor',
                    recipientName: doctor['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// This file defines the DoctorListScreen which displays a list of registered doctors.
import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/chwScreen/chw_chat_screen.dart';
// Ensure that the file 'chw_chat_screen.dart' exists in the 'screens' directory
// and that it defines a class named CHWChatScreen.

final List<Map<String, String>> registeredPatients = [
  {'id': 'p1', 'name': 'Aisha Musa'},
  {'id': 'p2', 'name': 'Fatima Ibrahim'},
];

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered Patients'), backgroundColor: Colors.teal),
      body: ListView.builder(
        itemCount: registeredPatients.length,
        itemBuilder: (context, index) {
          final patient = registeredPatients[index];
          return ListTile(
            title: Text(patient['name']!),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CHWChatScreen(
                    chatId: 'patient_chat_${patient['id']}',
                    recipientType: 'Patient',
                    recipientName: patient['name']!,
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
// This file defines the PatientListScreen which displays a list of registered patients.
// admin_patient_register_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPatientRegisterListScreen extends StatelessWidget {
  const AdminPatientRegisterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Register'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No registered patients found.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['fullName'] ?? 'No name';
              final email = data['email'] ?? 'No email';
              final phone = data['phone'] ?? 'No phone';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Text('Email: $email\nPhone: $phone'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

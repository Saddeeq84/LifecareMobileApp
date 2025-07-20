import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentHistoryTab extends StatelessWidget {
  final String role;
  final String? userId;

  const AppointmentHistoryTab({super.key, required this.role, required this.userId});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('appointments')
        .where(role == 'admin' ? 'status' : 'patientId', isEqualTo: role == 'admin' ? null : userId)
        .where('status', isNotEqualTo: 'pending');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final appointments = snapshot.data!.docs;

        if (appointments.isEmpty) {
          return const Center(child: Text("No appointment history"));
        }

        return ListView(
          children: appointments.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text("Staff ID: ${data['staffId']}"),
              subtitle: Text("Status: ${data['status']}"),
              trailing: Text("${(data['createdAt'] as Timestamp).toDate()}"),
            );
          }).toList(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingAppointmentTab extends StatelessWidget {
  final String role;
  final String? userId;

  const PendingAppointmentTab({super.key, required this.role, required this.userId});

  @override
  Widget build(BuildContext context) {
    final appointmentsQuery = FirebaseFirestore.instance.collection('appointments')
        .where('status', isEqualTo: 'pending')
        .where(role == 'admin' ? 'status' : 'patientId', isEqualTo: role == 'admin' ? null : userId);

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final appointments = snapshot.data!.docs;

        if (appointments.isEmpty) {
          return const Center(child: Text("No pending appointments"));
        }

        return ListView(
          children: appointments.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text("Staff ID: ${data['staffId']}"),
              subtitle: Text("Booked by: ${data['bookedByRole']}"),
              trailing: Text(data['status']),
            );
          }).toList(),
        );
      },
    );
  }
}

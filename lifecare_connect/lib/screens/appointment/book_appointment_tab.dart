// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentTab extends StatelessWidget {
  final String role;
  const BookAppointmentTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('staff').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final staffList = snapshot.data!.docs;

        return ListView.builder(
          itemCount: staffList.length,
          itemBuilder: (context, index) {
            final staff = staffList[index].data() as Map<String, dynamic>;
            final staffName = staff['name'];
            final staffId = staffList[index].id;

            return ListTile(
              title: Text(staffName),
              subtitle: Text(staff['role'] ?? ''),
              trailing: ElevatedButton(
                child: const Text("Book"),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('appointments').add({
                    'patientId': currentUserId,
                    'staffId': staffId,
                    'status': 'pending',
                    'createdAt': FieldValue.serverTimestamp(),
                    'bookedByRole': role,
                    'appointmentTime':FieldValue.serverTimestamp(),
                    'notes': 'reason or symptoms here',
                    'approvedBy': role,
                    'location': 'location here'
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Appointment booked ✅")),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

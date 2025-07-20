// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharedReferralWidget extends StatelessWidget {
  final String role; // 'doctor', 'chw', or 'admin'

  const SharedReferralWidget({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    Query referralQuery = FirebaseFirestore.instance.collection('referrals');

    // Filter based on role
    if (role == 'doctor') {
      referralQuery = referralQuery.where('toDoctorId', isEqualTo: currentUser?.uid);
    } else if (role == 'chw') {
      referralQuery = referralQuery.where('fromUserId', isEqualTo: currentUser?.uid);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: referralQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final referrals = snapshot.data!.docs;

        if (referrals.isEmpty) {
          return const Center(child: Text("No referrals found."));
        }

        return ListView.builder(
          itemCount: referrals.length,
          itemBuilder: (context, index) {
            final data = referrals[index].data() as Map<String, dynamic>;
            final status = data['status'];
            final referralId = referrals[index].id;

            return Card(
              child: ListTile(
                title: Text("Patient ID: ${data['patientId']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From: ${data['fromRole']}"),
                    Text("Notes: ${data['notes'] ?? ''}"),
                    Text("Status: ${status.toUpperCase()}"),
                  ],
                ),
                trailing: role == 'doctor' && status == 'pending'
                    ? IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('referrals')
                              .doc(referralId)
                              .update({
                            'status': 'approved',
                            'approvedBy': currentUser?.uid,
                          });

                          // Add patient to doctor's list (pseudo-code)
                          await FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(currentUser?.uid)
                              .collection('patients')
                              .doc(data['patientId'])
                              .set({'addedAt': Timestamp.now()});
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

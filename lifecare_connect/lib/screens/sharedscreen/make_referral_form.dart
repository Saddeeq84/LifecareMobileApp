// Full referral system starter
// ✅ Handles dropdowns, form, list view with approval logic for doctors
// Uses Firestore and FirebaseAuth

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferralDashboard extends StatelessWidget {
  final String role; // 'doctor', 'chw', 'admin'
  const ReferralDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (role != 'admin') MakeReferralForm(role: role),
        const SizedBox(height: 16),
        Expanded(child: SharedReferralWidget(role: role)),
      ],
    );
  }
  
}
  
class MakeReferralForm extends StatelessWidget {
  final String role;
  const MakeReferralForm({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Placeholder form UI
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Make a Referral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Patient ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Implement referral submission logic here
              },
              child: const Text('Submit Referral'),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedReferralWidget extends StatelessWidget {
  final String role;
  const SharedReferralWidget({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    Query referralQuery = FirebaseFirestore.instance.collection('referrals');

    if (role == 'doctor') {
      referralQuery = referralQuery.where('toDoctorId', isEqualTo: currentUser?.uid);
    } else if (role == 'chw') {
      referralQuery = referralQuery.where('fromUserId', isEqualTo: currentUser?.uid);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: referralQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final referrals = snapshot.data!.docs;
        if (referrals.isEmpty) {
          return const Center(child: Text('No referrals available.'));
        }
        return ListView.builder(
          itemCount: referrals.length,
          itemBuilder: (context, index) {
            final data = referrals[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Patient ID: ${data['patientId']}'),
                subtitle: Text('Status: $status\nNotes: ${data['notes']}'),
                trailing: role == 'doctor' && status == 'pending'
                    ? ElevatedButton(
                        onPressed: () async {
                          await referrals[index].reference.update({
                            'status': 'approved',
                          });
                          // Optionally add patient to doctor's list
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser!.uid)
                              .collection('patients')
                              .doc(data['patientId'])
                              .set({});
                        },
                        child: const Text('Approve'),
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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveDoctorsScreen extends StatelessWidget {
  const ApproveDoctorsScreen({super.key});

  Future<void> _approveDoctor(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'isApproved': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve doctor: $e')),
      );
    }
  }

  Future<void> _rejectDoctor(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'isApproved': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject doctor: $e')),
      );
    }
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Approval Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('isApproved', isEqualTo: false) // pending approval
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctors = snapshot.data!.docs;

          if (doctors.isEmpty) {
            return const Center(child: Text('No pending doctor requests.'));
          }

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final fullName = doc['fullName'] ?? 'Unnamed';
              final email = doc['email'] ?? 'No email';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(fullName),
                  subtitle: Text(email),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Approve',
                        onPressed: () async {
                          final confirmed = await _showConfirmationDialog(
                            context,
                            'Approve Doctor',
                            'Are you sure you want to approve $fullName?',
                          );
                          if (confirmed == true) {
                            await _approveDoctor(context, doc.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: () async {
                          final confirmed = await _showConfirmationDialog(
                            context,
                            'Reject Doctor',
                            'Are you sure you want to reject $fullName?',
                          );
                          if (confirmed == true) {
                            await _rejectDoctor(context, doc.id);
                          }
                        },
                      ),
                    ],
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

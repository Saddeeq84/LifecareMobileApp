// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveFacilitiesScreen extends StatelessWidget {
  const ApproveFacilitiesScreen({super.key});

  Future<void> _approveFacility(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('facilities').doc(docId).update({
        'isApproved': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facility approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving facility: $e')),
      );
    }
  }

  Future<void> _rejectFacility(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('facilities').doc(docId).update({
        'isApproved': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facility rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting facility: $e')),
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
      appBar: AppBar(title: const Text('Facility Approval Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('facilities')
            .where('isApproved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final facilities = snapshot.data!.docs;

          if (facilities.isEmpty) {
            return const Center(child: Text('No pending facility requests.'));
          }

          return ListView.builder(
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final doc = facilities[index];
              final name = doc['facilityName'] ?? 'Unnamed Facility';
              final type = doc['facilityType'] ?? 'Unknown Type';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(type),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Approve',
                        onPressed: () async {
                          final confirm = await _showConfirmationDialog(
                            context,
                            'Approve Facility',
                            'Are you sure you want to approve "$name"?',
                          );
                          if (confirm == true) {
                            await _approveFacility(context, doc.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: () async {
                          final confirm = await _showConfirmationDialog(
                            context,
                            'Reject Facility',
                            'Are you sure you want to reject "$name"?',
                          );
                          if (confirm == true) {
                            await _rejectFacility(context, doc.id);
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

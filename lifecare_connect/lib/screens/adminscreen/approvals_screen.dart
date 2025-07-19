// approvals_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approve Accounts'),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Doctors'),
              Tab(text: 'Facilities'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ApprovalList(role: null, isApproved: false),         // Pending All
            _ApprovalList(role: 'doctor', isApproved: true),      // Approved Doctors
            _ApprovalList(role: 'facility', isApproved: true),    // Approved Facilities
          ],
        ),
      ),
    );
  }
}

class _ApprovalList extends StatelessWidget {
  final String? role;
  final bool isApproved;

  const _ApprovalList({
    required this.role,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('users');

    if (role == null) {
      // Pending users (doctors or facilities)
      query = query
          .where('role', whereIn: ['doctor', 'facility'])
          .where('isApproved', isEqualTo: false);
    } else {
      query = query
          .where('role', isEqualTo: role)
          .where('isApproved', isEqualTo: isApproved);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('❌ Error loading users'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = docs[index].data();
            final fullName = user['fullName'] ?? user['name'] ?? 'Unnamed User';
            final email = user['email'] ?? 'No Email';
            final userRole = user['role'] ?? 'Unknown';

            return ListTile(
              leading: const Icon(Icons.account_circle, size: 32),
              title: Text(fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  Text("Role: $userRole", style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: !isApproved
                  ? ElevatedButton(
                      onPressed: () =>
                          _approveUser(docs[index].id, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Approve'),
                    )
                  : const Icon(Icons.check_circle, color: Colors.green),
            );
          },
        );
      },
    );
  }

  Future<void> _approveUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isApproved': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ User approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Approval failed: $e')),
      );
    }
  }
}

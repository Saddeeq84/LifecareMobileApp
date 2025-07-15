import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

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
            _ApprovalList(role: null, approved: false),
            _ApprovalList(role: 'doctor', approved: true),
            _ApprovalList(role: 'facility', approved: true),
          ],
        ),
      ),
    );
  }
}

class _ApprovalList extends StatelessWidget {
  final String? role;
  final bool approved;

  const _ApprovalList({this.role, required this.approved});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('users');

    if (role != null) {
      query = query.where('role', isEqualTo: role);
    } else {
      // For pending approvals (no role filter, just approved == false)
      query = query.where('approved', isEqualTo: false);
    }

    if (approved) {
      query = query.where('approved', isEqualTo: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user['fullName'] ?? 'Unknown'),
              subtitle: Text(user['email'] ?? 'No email'),
              trailing: approved
                  ? null
                  : ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(docs[index].id)
                            .update({'approved': true});
                      },
                      child: const Text('Approve'),
                    ),
            );
          },
        );
      },
    );
  }
}

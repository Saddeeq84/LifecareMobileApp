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
            _ApprovalList(role: null, approved: false),         // Pending
            _ApprovalList(role: 'doctor', approved: true),      // Approved Doctors
            _ApprovalList(role: 'facility', approved: true),    // Approved Facilities
          ],
        ),
      ),
    );
  }
}

class _ApprovalList extends StatelessWidget {
  final String? role;
  final bool approved;

  const _ApprovalList({
    required this.role,
    required this.approved,
  });

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users');

    if (role == null) {
      // Show users who are not yet approved
      query = query.where('approved', isEqualTo: false);
    } else {
      query = query
          .where('role', isEqualTo: role)
          .where('approved', isEqualTo: approved);
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
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final fullName = data['fullName'] ?? 'Unnamed User';
            final email = data['email'] ?? 'No Email';

            return ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(fullName),
              subtitle: Text(email),
              trailing: !approved
                  ? ElevatedButton(
                      onPressed: () => _approveUser(docs[index].id, context),
                      child: const Text('Approve'),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  void _approveUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'approved': true});
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

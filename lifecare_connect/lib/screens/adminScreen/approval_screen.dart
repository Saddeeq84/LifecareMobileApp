import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isApproved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ User approved')),
    );
  }

  Future<void> rejectUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ User rejected and deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve New Accounts'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('isApproved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending approvals.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final uid = users[index].id;
              final name = data['fullName'] ?? 'No Name';
              final email = data['email'] ?? '';
              final role = data['role'] ?? 'unknown';
              final phone = data['phone'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('$name (${role.toUpperCase()})'),
                  subtitle: Text('Email: $email\nPhone: $phone'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => approveUser(uid),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => rejectUser(uid),
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

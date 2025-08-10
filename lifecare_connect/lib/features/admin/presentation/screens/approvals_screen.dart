// approvals_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifecare_connect/core/utils/email_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approve Accounts'),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'CHWs'),
              Tab(text: 'Doctors'),
              Tab(text: 'Facilities'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ApprovalList(role: null, isApproved: false),         // Pending All
            _ApprovalList(role: 'chw', isApproved: null),         // CHW Approvals (both pending and approved)
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
  final bool? isApproved; // Made nullable to show both pending and approved CHWs

  const _ApprovalList({
    required this.role,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('users');

    if (role == null) {
      // Pending users (doctors, facilities, and CHWs)
      query = query
          .where('role', whereIn: ['doctor', 'facility', 'chw'])
          .where('isApproved', isEqualTo: false);
    } else if (role == 'chw') {
      // CHWs (both pending and approved) - special case for CHW management
      query = query.where('role', isEqualTo: 'chw');
    } else {
      // Specific role with approval status
      query = query
          .where('role', isEqualTo: role)
          .where('isApproved', isEqualTo: isApproved!);
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
                  if (userRole == 'chw')
                    Text(
                      user['isApproved'] == true ? "Status: Approved" : "Status: Pending",
                      style: TextStyle(
                        fontSize: 12,
                        color: user['isApproved'] == true ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: (isApproved == null && user['isApproved'] != true) || (isApproved == false)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Review Account Details'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        for (final entry in user.entries)
                                          if (entry.value != null && entry.value.toString().isNotEmpty && entry.key != 'password' && entry.key != 'isApproved' && entry.key != 'licenseFile' && entry.key != 'govDocument')
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 15)),
                                            ),
                                        // Show license file for doctor
                                        if ((user['role'] == 'doctor' || user['role'] == 'facility') && (user['licenseFile'] != null || user['govDocument'] != null))
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (user['role'] == 'doctor' && user['licenseFile'] != null)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('License Document:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 4),
                                                      InkWell(
                                                        onTap: () async {
                                                          final url = user['licenseFile'];
                                                          final uri = Uri.tryParse(url);
                                                          if (uri != null && await canLaunchUrl(uri)) {
                                                            await launchUrl(uri);
                                                          }
                                                        },
                                                        child: Text(
                                                          user['licenseFile'],
                                                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (user['role'] == 'facility' && user['govDocument'] != null)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('Government Document:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 4),
                                                      InkWell(
                                                        onTap: () async {
                                                          final url = user['govDocument'];
                                                          final uri = Uri.tryParse(url);
                                                          if (uri != null && await canLaunchUrl(uri)) {
                                                            await launchUrl(uri);
                                                          }
                                                        },
                                                        child: Text(
                                                          user['govDocument'],
                                                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _approveUser(docs[index].id, context);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                      child: const Text('Approve'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Review'),
                        ),
                      ],
                    )
                  : (user['isApproved'] == true && (userRole == 'chw' || userRole == 'doctor' || userRole == 'facility'))
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Revoke'),
                                    content: const Text('Are you sure you want to revoke this account approval?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Revoke'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _revokeUser(docs[index].id, context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(60, 32),
                              ),
                              child: const Text('Revoke', style: TextStyle(fontSize: 12)),
                            ),
                          ],
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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isApproved': true});
      if (userData != null && userData['email'] != null && (userData['role'] == 'doctor' || userData['role'] == 'chw' || userData['role'] == 'facility')) {
        final name = userData['fullName'] ?? userData['name'] ?? '';
        await sendAccountApprovedEmail(userData['email'], name);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ User approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Approval failed: $e')),
      );
    }
  }

  Future<void> _revokeUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isApproved': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ User approval revoked')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Revoke failed: $e')),
      );
    }
  }
}

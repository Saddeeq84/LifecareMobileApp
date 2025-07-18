// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReferralsScreen extends StatefulWidget {
  const DoctorReferralsScreen({super.key});

  @override
  State<DoctorReferralsScreen> createState() => _DoctorReferralsScreenState();
}

class _DoctorReferralsScreenState extends State<DoctorReferralsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  /// Handles the doctor's decision on a referral (Accept or Reject).
  Future<void> _handleReferralDecision(
      DocumentSnapshot referralDoc, String decision) async {
    try {
      await referralDoc.reference.update({
        'status': decision,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Referral $decision')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update referral: $e')),
      );
    }
  }

  /// Builds each referral card item with action buttons.
  Widget _buildReferralCard(
      Map<String, dynamic> data, DocumentSnapshot doc,
      {bool isReviewed = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(data['patient'] ?? 'Unknown Patient'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Condition: ${data['condition'] ?? 'N/A'}"),
            Text("Referred by: ${data['chw'] ?? 'Unknown'}"),
            if (isReviewed) Text("Status: ${data['status']}"),
          ],
        ),
        trailing: isReviewed
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Accept",
                    onPressed: () =>
                        _handleReferralDecision(doc, 'Accepted'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Reject",
                    onPressed: () =>
                        _handleReferralDecision(doc, 'Rejected'),
                  ),
                ],
              ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Viewing details for ${data['patient']}")),
          );
        },
      ),
    );
  }

  /// Builds the list view of referrals filtered by status
  Widget _buildReferralList({required bool isReviewed}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('referrals')
          .where('status', isEqualTo: isReviewed ? 'Accepted' : 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(isReviewed
                ? "No reviewed referrals yet."
                : "No pending referrals."),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildReferralCard(data, doc, isReviewed: isReviewed);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Main UI build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Referrals"),
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Reviewed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReferralList(isReviewed: false),
          _buildReferralList(isReviewed: true),
        ],
      ),
    );
  }
}

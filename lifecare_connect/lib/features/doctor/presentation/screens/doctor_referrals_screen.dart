// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/data/services/message_service.dart';

class DoctorReferralsScreen extends StatefulWidget {
  const DoctorReferralsScreen({super.key});

  @override
  State<DoctorReferralsScreen> createState() => _DoctorReferralsScreenState();
}

class _DoctorReferralsScreenState extends State<DoctorReferralsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Referrals"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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

  /// Handles the doctor's decision on a referral (Accept or Reject).
  Future<void> _handleReferralDecision(
      BuildContext context, DocumentSnapshot referralDoc, String decision) async {
    
    String? rejectionReason;
    
    // If rejecting, ask for reason
    if (decision == 'Rejected') {
      rejectionReason = await _showRejectionReasonDialog(context);
      if (rejectionReason == null || rejectionReason.isEmpty) {
        return; // User cancelled
      }
    }
    
    try {
      final updateData = {
        'status': decision,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': FirebaseAuth.instance.currentUser?.uid,
      };
      
      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }
      
      await referralDoc.reference.update(updateData);

      // Send notification message to CHW
      await _sendReferralDecisionMessage(referralDoc, decision, rejectionReason);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Referral $decision and CHW notified')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update referral: $e')),
      );
    }
  }

  Future<String?> _showRejectionReasonDialog(BuildContext context) async {
    String rejectionReason = '';
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reason for Rejection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for rejecting this referral:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => rejectionReason = value,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter reason for rejection...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (rejectionReason.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(rejectionReason.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject Referral', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendReferralDecisionMessage(
    DocumentSnapshot referralDoc, 
    String decision, 
    String? rejectionReason
  ) async {
    try {
      final referralData = referralDoc.data() as Map<String, dynamic>;
      final chwId = referralData['chwId'] ?? referralData['referringProviderId'];
      final patientName = referralData['patient'] ?? referralData['patientName'] ?? 'Patient';
      final condition = referralData['condition'] ?? referralData['reason'] ?? 'Not specified';
      
      if (chwId == null) {
        print('❌ CHW ID not found in referral');
        return;
      }
      
      // Get current doctor details
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Current user not found');
        return;
      }
      
      final doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!doctorDoc.exists) {
        print('❌ Doctor user data not found');
        return;
      }
      
      final doctorData = doctorDoc.data() as Map<String, dynamic>;
      final doctorName = '${doctorData['firstName'] ?? ''} ${doctorData['lastName'] ?? ''}'.trim();
      final doctorRole = doctorData['role'] ?? 'doctor';
      final doctorSpecialization = doctorData['specialization'] ?? 'Doctor';
      
      // Get CHW details
      final chwDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(chwId)
          .get();
      
      if (!chwDoc.exists) {
        print('❌ CHW user data not found');
        return;
      }
      
      final chwData = chwDoc.data() as Map<String, dynamic>;
      final chwName = '${chwData['firstName'] ?? ''} ${chwData['lastName'] ?? ''}'.trim();
      final chwRole = chwData['role'] ?? 'CHW';
      
      // Create message content based on decision
      String messageContent;
      
      if (decision == 'Accepted') {
        messageContent = '''
✅ Referral Accepted

Dear $chwName,

I am pleased to inform you that the referral for patient $patientName has been accepted.

👨‍⚕️ Reviewing Doctor: Dr. $doctorName ($doctorSpecialization)
🏥 Condition: $condition
📋 Status: Approved for consultation

Please inform the patient that they can proceed to schedule an appointment with me. I will ensure they receive the appropriate care and attention for their condition.

If you have any questions or need additional information, please don't hesitate to contact me.

Best regards,
Dr. $doctorName
$doctorSpecialization
''';
      } else {
        messageContent = '''
🚫 Referral Rejected

Dear $chwName,

I regret to inform you that the referral for patient $patientName has been rejected.

👨‍⚕️ Reviewing Doctor: Dr. $doctorName ($doctorSpecialization)
🏥 Condition: $condition
❌ Status: Rejected

Reason for rejection: $rejectionReason

Please review the patient's condition and consider alternative care options or consult with another specialist if appropriate. If you have any questions about this decision, please feel free to contact me.

Best regards,
Dr. $doctorName
$doctorSpecialization
''';
      }
      
      // Create or get conversation and send message
      final conversationId = await MessageService.createOrGetConversation(
        user1Id: currentUser.uid,
        user1Name: doctorName,
        user1Role: doctorRole,
        user2Id: chwId,
        user2Name: chwName,
        user2Role: chwRole,
        type: 'referral_related',
        relatedId: referralDoc.id,
        title: 'Referral Update',
      );
      
      await MessageService.sendMessage(
        conversationId: conversationId,
        senderId: currentUser.uid,
        senderName: doctorName,
        senderRole: doctorRole,
        receiverId: chwId,
        receiverName: chwName,
        receiverRole: chwRole,
        content: messageContent,
        type: 'referral_notification',
        priority: 'high',
      );
      
      print('✅ Referral decision message sent to CHW successfully');
    } catch (e) {
      print('❌ Error sending referral decision message: $e');
    }
  }

  /// Builds each referral card item with action buttons.
  Widget _buildReferralCard(
      BuildContext context, Map<String, dynamic> data, DocumentSnapshot doc,
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
                        _handleReferralDecision(context, doc, 'Accepted'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Reject",
                    onPressed: () =>
                        _handleReferralDecision(context, doc, 'Rejected'),
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
            return _buildReferralCard(context, data, doc, isReviewed: isReviewed);
          },
        );
      },
    );
  }


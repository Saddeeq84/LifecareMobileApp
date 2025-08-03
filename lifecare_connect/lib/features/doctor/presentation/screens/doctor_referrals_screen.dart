// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors
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
  void _showReferralDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Referral Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: [200b${data['patient'] ?? data['patientName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (data['patientId'] != null) Text('Patient ID: ${data['patientId']}'),
              if (data['age'] != null) Text('Age: ${data['age']}'),
              if (data['gender'] != null) Text('Gender: ${data['gender']}'),
              const SizedBox(height: 8),
              Text('Referred by: ${data['chw'] ?? data['referringProviderName'] ?? 'Unknown'}'),
              if (data['chwId'] != null) Text('CHW ID: ${data['chwId']}'),
              if (data['referralDate'] != null) Text('Referral Date: ${data['referralDate']}'),
              const Divider(),
              Text('Condition/Reason: ${data['condition'] ?? data['reason'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (data['urgency'] != null) Text('Urgency: ${data['urgency']}'),
              if (data['type'] != null) Text('Type: ${data['type']}'),
              if (data['status'] != null) Text('Status: ${data['status']}'),
              if (data['notes'] != null && (data['notes'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data['notes']),
              ],
              if (data['additionalInfo'] != null && (data['additionalInfo'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Additional Info:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data['additionalInfo']),
              ],
              if (data['attachments'] != null) ...[
                const SizedBox(height: 8),
                Text('Attachments: ${data['attachments']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
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

  Widget _buildReferralList({required bool isReviewed}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('User not logged in.'));
    }
    final doctorId = currentUser.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('referrals')
          .where('toProviderId', isEqualTo: doctorId)
          .where('status', isEqualTo: isReviewed ? 'Accepted' : 'pending')
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
          }
        );
      },
    );
  }

  /// Builds each referral card item with action buttons.
  Widget _buildReferralCard(
      BuildContext context, Map<String, dynamic> data, DocumentSnapshot doc,
      {bool isReviewed = false}) {
    return FutureBuilder<String>(
      future: _getPatientName(data),
      builder: (context, snapshot) {
        final patientName = snapshot.data ?? data['patient'] ?? 'Unknown Patient';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(patientName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Condition: "+(data['condition'] ?? 'N/A')),
                Text("Referred by: "+(data['chw'] ?? 'Unknown')),
                if (isReviewed) Text("Status: "+(data['status'] ?? '')),
              ],
            ),
            trailing: isReviewed
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                        tooltip: "Review Referral",
                        onPressed: () => _showReferralDetailsDialog(context, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: "Approve",
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Approval'),
                              content: const Text('Are you sure you want to approve this referral?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _handleReferralDecision(context, doc, 'Accepted');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: "Deny",
                        onPressed: () => _handleReferralDecision(context, doc, 'Rejected'),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // Helper to fetch patient name from users collection if only patientId is present
  Future<String> _getPatientName(Map<String, dynamic> data) async {
    if (data['patient'] != null && data['patient'].toString().trim().isNotEmpty) {
      return data['patient'];
    }
    final patientId = data['patientId'];
    if (patientId == null) return 'Unknown Patient';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(patientId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        return userData['fullName'] ?? userData['name'] ?? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
      }
    } catch (_) {}
    return 'Unknown Patient';
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

  /// Handles the doctor's decision on a referral (Accept or Reject).
  Future<void> _handleReferralDecision(
      BuildContext context, DocumentSnapshot referralDoc, String decision) async {
    String? rejectionReason;
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
      await _sendReferralDecisionMessage(referralDoc, decision, rejectionReason);

      // Send message to patient as well
      final referralData = referralDoc.data() as Map<String, dynamic>;
      final patientId = referralData['patientId'] ?? referralData['patientUid'];
      final patientName = referralData['patient'] ?? referralData['patientName'] ?? 'Patient';
      final doctor = FirebaseAuth.instance.currentUser;
      final doctorName = doctor?.displayName ?? 'Doctor';
      String patientMsg;
      if (decision == 'Accepted') {
        patientMsg = 'Your referral to Dr. $doctorName has been approved. Please check your app for next steps.';
      } else {
        patientMsg = 'Your referral to Dr. $doctorName was denied. Reason: $rejectionReason';
      }
      if (patientId != null) {
        await FirebaseFirestore.instance.collection('messages').add({
          'conversationId': patientId,
          'senderId': doctor?.uid,
          'senderName': doctorName,
          'senderRole': 'doctor',
          'receiverId': patientId,
          'receiverName': patientName,
          'receiverRole': 'patient',
          'content': patientMsg,
          'type': 'referral_notification',
          'priority': 'high',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // On approval, create consultation document if not present
      if (decision == 'Accepted' && patientId != null) {
        try {
          final consultations = await FirebaseFirestore.instance
              .collection('consultations')
              .where('appointmentId', isEqualTo: referralDoc.id)
              .get();
          if (consultations.docs.isEmpty) {
            final consultationData = {
              'appointmentId': referralDoc.id,
              'patientUid': patientId,
              'patientName': patientName,
              'providerId': doctor?.uid ?? '',
              'providerName': doctorName,
              'status': 'approved',
              'createdAt': FieldValue.serverTimestamp(),
              'type': referralData['type'] ?? 'referral',
              'reason': referralData['condition'] ?? referralData['reason'] ?? '',
              'source': 'referral',
              'referralId': referralDoc.id,
              'referralDetails': {
                'chwId': referralData['chwId'] ?? referralData['referringProviderId'] ?? '',
                'chwName': referralData['chw'] ?? referralData['referringProviderName'] ?? '',
                'referralDate': referralData['referralDate'] ?? '',
                'urgency': referralData['urgency'] ?? '',
                'notes': referralData['notes'] ?? '',
                'additionalInfo': referralData['additionalInfo'] ?? '',
                'attachments': referralData['attachments'] ?? '',
              },
            };
            print('[DEBUG] Creating consultation for approved referral: $consultationData');
            await FirebaseFirestore.instance.collection('consultations').add(consultationData);
          } else {
            print('[DEBUG] Consultation already exists for referral ${referralDoc.id}');
          }
        } catch (e) {
          print('[ERROR] Failed to create consultation for approved referral: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Referral $decision and notifications sent')),
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
}


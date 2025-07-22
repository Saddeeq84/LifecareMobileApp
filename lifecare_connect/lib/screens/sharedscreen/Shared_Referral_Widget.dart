// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharedReferralWidget extends StatefulWidget {
  final String role; // 'doctor', 'chw', 'facility', 'admin', or 'patient'

  const SharedReferralWidget({super.key, required this.role});

  @override
  State<SharedReferralWidget> createState() => _SharedReferralWidgetState();
}

class _SharedReferralWidgetState extends State<SharedReferralWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller based on role
    int tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    switch (widget.role) {
      case 'doctor':
      case 'chw':
      case 'facility':
        return 3; // Sent, Received, All
      case 'admin':
        return 1; // All referrals only
      case 'patient':
        return 1; // Approved referrals only
      default:
        return 1;
    }
  }

  List<Tab> _getTabs() {
    switch (widget.role) {
      case 'doctor':
      case 'chw':
      case 'facility':
        return const [
          Tab(text: 'Sent'),
          Tab(text: 'Received'),
          Tab(text: 'All'),
        ];
      case 'admin':
        return const [Tab(text: 'All Referrals')];
      case 'patient':
        return const [Tab(text: 'My Referrals')];
      default:
        return const [Tab(text: 'Referrals')];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'admin' || widget.role == 'patient') {
      return _buildSingleView();
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: _getTabs(),
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReferralList('sent'),
              _buildReferralList('received'),
              _buildReferralList('all'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleView() {
    if (widget.role == 'admin') {
      return _buildReferralList('admin');
    } else if (widget.role == 'patient') {
      return _buildReferralList('patient');
    }
    return const Center(child: Text('No referrals available'));
  }

  Widget _buildReferralList(String type) {
    Query referralQuery = FirebaseFirestore.instance.collection('referrals');

    // Apply filters based on role and type
    switch (widget.role) {
      case 'doctor':
        if (type == 'sent') {
          referralQuery = referralQuery.where('fromUserId', isEqualTo: currentUser?.uid)
              .where('fromRole', isEqualTo: 'doctor');
        } else if (type == 'received') {
          referralQuery = referralQuery.where('toUserId', isEqualTo: currentUser?.uid)
              .where('toRole', isEqualTo: 'doctor');
        }
        break;
        
      case 'chw':
        if (type == 'sent') {
          referralQuery = referralQuery.where('fromUserId', isEqualTo: currentUser?.uid)
              .where('fromRole', isEqualTo: 'chw');
        } else if (type == 'received') {
          referralQuery = referralQuery.where('toUserId', isEqualTo: currentUser?.uid)
              .where('toRole', isEqualTo: 'chw');
        }
        break;
        
      case 'facility':
        if (type == 'sent') {
          referralQuery = referralQuery.where('fromUserId', isEqualTo: currentUser?.uid)
              .where('fromRole', isEqualTo: 'facility');
        } else if (type == 'received') {
          referralQuery = referralQuery.where('toUserId', isEqualTo: currentUser?.uid)
              .where('toRole', isEqualTo: 'facility');
        }
        break;
        
      case 'patient':
        referralQuery = referralQuery.where('patientId', isEqualTo: currentUser?.uid)
            .where('status', isEqualTo: 'approved');
        break;
        
      case 'admin':
        // Admin sees all referrals - no additional filter
        break;
    }

    referralQuery = referralQuery.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: referralQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_information_outlined, 
                     size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No referrals found', 
                     style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final referrals = snapshot.data!.docs;

        return ListView.builder(
          itemCount: referrals.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final data = referrals[index].data() as Map<String, dynamic>;
            final referralId = referrals[index].id;
            return _buildReferralCard(data, referralId);
          },
        );
      },
    );
  }

  Widget _buildReferralCard(Map<String, dynamic> data, String referralId) {
    final status = data['status'] ?? 'pending';
    final patientName = data['patientName'] ?? 'Unknown Patient';
    final reason = data['reason'] ?? 'No reason provided';
    final fromRole = data['fromRole'] ?? 'Unknown';
    final toRole = data['toRole'] ?? 'Unknown';
    final urgency = data['urgency'] ?? 'normal';
    final createdAt = data['createdAt'] as Timestamp?;

    Color statusColor = _getStatusColor(status);
    Color urgencyColor = _getUrgencyColor(urgency);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with patient name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Referral details
            Text('From: ${fromRole.toUpperCase()} → To: ${toRole.toUpperCase()}'),
            const SizedBox(height: 4),
            Text('Reason: $reason'),
            const SizedBox(height: 4),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    urgency.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (createdAt != null)
                  Text(
                    '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            
            // Action buttons based on role and permissions
            if (_shouldShowActions(data, status))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildActionButtons(data, referralId, status),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowActions(Map<String, dynamic> data, String status) {
    switch (widget.role) {
      case 'doctor':
        // Doctors can approve/reject referrals sent to them, but cannot delete
        return (data['toUserId'] == currentUser?.uid && status == 'pending') ||
               (data['fromUserId'] == currentUser?.uid && status == 'pending');
               
      case 'chw':
        // CHWs can approve/confirm receipt of referrals from doctors only
        return (data['toUserId'] == currentUser?.uid && 
                data['fromRole'] == 'doctor' && status == 'pending');
                
      case 'facility':
        // Facilities can accept/reject referrals sent to them
        return (data['toUserId'] == currentUser?.uid && status == 'pending');
        
      case 'admin':
        // Admin can delete referrals but cannot approve/edit/reject
        return true;
        
      case 'patient':
        // Patients can only acknowledge approved referrals
        return status == 'approved' && data['patientAcknowledged'] != true;
        
      default:
        return false;
    }
  }

  Widget _buildActionButtons(Map<String, dynamic> data, String referralId, String status) {
    List<Widget> buttons = [];

    switch (widget.role) {
      case 'doctor':
        if (data['toUserId'] == currentUser?.uid && status == 'pending') {
          buttons.addAll([
            ElevatedButton.icon(
              onPressed: () => _handleReferralAction(referralId, 'approved'),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _handleReferralAction(referralId, 'rejected'),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ]);
        }
        break;
        
      case 'chw':
        if (data['toUserId'] == currentUser?.uid && data['fromRole'] == 'doctor' && status == 'pending') {
          buttons.add(
            ElevatedButton.icon(
              onPressed: () => _handleReferralAction(referralId, 'confirmed'),
              icon: const Icon(Icons.receipt_long, size: 16),
              label: const Text('Confirm Receipt'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          );
        }
        break;
        
      case 'facility':
        if (data['toUserId'] == currentUser?.uid && status == 'pending') {
          buttons.addAll([
            ElevatedButton.icon(
              onPressed: () => _showReasonDialog(referralId, 'accepted'),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showReasonDialog(referralId, 'rejected'),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ]);
        }
        break;
        
      case 'admin':
        buttons.add(
          ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmation(referralId),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        );
        break;
        
      case 'patient':
        if (status == 'approved' && data['patientAcknowledged'] != true) {
          buttons.add(
            ElevatedButton.icon(
              onPressed: () => _handlePatientAcknowledgment(referralId, data),
              icon: const Icon(Icons.thumb_up, size: 16),
              label: const Text('Acknowledge'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          );
        }
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: buttons,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'accepted':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
      case 'denied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleReferralAction(String referralId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(referralId)
          .update({
        'status': newStatus,
        'actionBy': currentUser?.uid,
        'actionDate': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Referral $newStatus successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating referral: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showReasonDialog(String referralId, String action) async {
    String reason = '';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'accepted' ? 'Accept' : 'Reject'} Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for ${action == 'accepted' ? 'accepting' : 'rejecting'} this referral:'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => reason = value,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleReferralActionWithReason(referralId, action, reason);
            },
            child: Text(action == 'accepted' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReferralActionWithReason(String referralId, String action, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(referralId)
          .update({
        'status': action,
        'actionBy': currentUser?.uid,
        'actionDate': FieldValue.serverTimestamp(),
        'actionReason': reason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Referral $action successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating referral: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(String referralId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Referral'),
        content: const Text('Are you sure you want to delete this referral? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('referrals')
            .doc(referralId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Referral deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting referral: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handlePatientAcknowledgment(String referralId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(referralId)
          .update({
        'patientAcknowledged': true,
        'patientAcknowledgedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Referral acknowledged successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error acknowledging referral: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

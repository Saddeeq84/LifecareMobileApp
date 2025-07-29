// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/message_service.dart';

class BroadcastMessageScreen extends StatefulWidget {
  const BroadcastMessageScreen({Key? key}) : super(key: key);

  @override
  _BroadcastMessageScreenState createState() => _BroadcastMessageScreenState();
}

class _BroadcastMessageScreenState extends State<BroadcastMessageScreen> {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  String _selectedCategory = 'all';
  bool _isSending = false;
  final List<String> _selectedFacilities = [];
  
  final Map<String, String> _categories = {
    'all': 'All Users',
    'patient': 'All Patients',
    'CHW': 'All Community Health Workers',
    'doctor': 'All Doctors',
    'facility_admin': 'All Facility Administrators',
    'specific_facility': 'Specific Facility Users',
  };

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Message'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE53935).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Color(0xFFE53935), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator Broadcast',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Send messages to multiple users at once. Use responsibly.',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Target Audience Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.group, color: Color(0xFFE53935)),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Target Audience',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.people),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedFacilities.clear();
                          });
                        },
                        items: _categories.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ),
                      if (_selectedCategory == 'specific_facility') ...[
                        const SizedBox(height: 16),
                        _buildFacilitySelector(),
                      ],
                      const SizedBox(height: 16),
                      _buildAudiencePreview(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Message Composition
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.message, color: Color(0xFFE53935)),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Message Content',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.subject),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 120),
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSendMessage() ? _sendBroadcastMessage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isSending
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Sending Broadcast...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.campaign, size: 24),
                            SizedBox(width: 8),
                            Text('Send Broadcast Message', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitySelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('facilities')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No facilities found');
        }

        final facilities = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Facilities:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  final facility = facilities[index];
                  final facilityData = facility.data() as Map<String, dynamic>;
                  final facilityName = facilityData['name'] ?? 'Unnamed Facility';
                  final facilityId = facility.id;

                  return CheckboxListTile(
                    title: Text(facilityName),
                    value: _selectedFacilities.contains(facilityId),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedFacilities.add(facilityId);
                        } else {
                          _selectedFacilities.remove(facilityId);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudiencePreview() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTargetUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Calculating audience...'),
            ],
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final userCount = snapshot.data?.docs.length ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFFE53935), size: 20),
              const SizedBox(width: 8),
              Text(
                'This message will be sent to $userCount users',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getTargetUsersStream() {
    Query query = FirebaseFirestore.instance.collection('users');
    
    // Exclude current user
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      query = query.where(FieldPath.documentId, isNotEqualTo: currentUserId);
    }
    
    if (_selectedCategory != 'all' && _selectedCategory != 'specific_facility') {
      query = query.where('role', isEqualTo: _selectedCategory);
    } else if (_selectedCategory == 'specific_facility' && _selectedFacilities.isNotEmpty) {
      query = query.where('facilityId', whereIn: _selectedFacilities);
    }
    
    return query.snapshots();
  }

  bool _canSendMessage() {
    final hasValidCategory = _selectedCategory != 'specific_facility' || _selectedFacilities.isNotEmpty;
    return _subjectController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty &&
        hasValidCategory &&
        !_isSending;
  }

  Future<void> _sendBroadcastMessage() async {
    if (!_canSendMessage()) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Broadcast'),
        content: const Text(
          'Are you sure you want to send this message to all selected users? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Send Broadcast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Get current user (admin) details
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!adminDoc.exists) {
        throw Exception('Admin user data not found');
      }

      final adminData = adminDoc.data() as Map<String, dynamic>;
      final adminFirstName = adminData['firstName'] ?? '';
      final adminLastName = adminData['lastName'] ?? '';
      final adminName = '$adminFirstName $adminLastName'.trim();
      final adminRole = adminData['role'] ?? 'admin';

      // Get target users
      final usersSnapshot = await _getTargetUsersStream().first;
      final targetUsers = usersSnapshot.docs;

      if (targetUsers.isEmpty) {
        throw Exception('No users found for the selected category');
      }

      // Format the broadcast message
      final messageContent = '''
📢 BROADCAST MESSAGE

Subject: ${_subjectController.text.trim()}

${_messageController.text.trim()}

---
This is a broadcast message from LifeCare Connect Administration.
Category: ${_categories[_selectedCategory]}
Sent by: $adminName
Date: ${DateTime.now().toString().split('.')[0]}
''';

      int successCount = 0;
      int failureCount = 0;

      // Send message to each user
      for (final userDoc in targetUsers) {
        try {
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (userData == null) continue;
          
          final userFirstName = userData['firstName'] ?? '';
          final userLastName = userData['lastName'] ?? '';
          final userName = '$userFirstName $userLastName'.trim();
          final userRole = userData['role'] ?? 'user';

          // Create conversation
          final conversationId = await MessageService.createOrGetConversation(
            user1Id: currentUser.uid,
            user1Name: adminName.isNotEmpty ? adminName : 'Admin',
            user1Role: adminRole,
            user2Id: userDoc.id,
            user2Name: userName.isNotEmpty ? userName : (userData['email'] ?? 'User'),
            user2Role: userRole,
            type: 'broadcast_message',
            title: 'Broadcast: ${_subjectController.text.trim()}',
          );

          // Send message
          await MessageService.sendMessage(
            conversationId: conversationId,
            senderId: currentUser.uid,
            senderName: adminName.isNotEmpty ? adminName : 'Admin',
            senderRole: adminRole,
            receiverId: userDoc.id,
            receiverName: userName.isNotEmpty ? userName : (userData['email'] ?? 'User'),
            receiverRole: userRole,
            content: messageContent,
            type: 'broadcast_message',
            priority: 'high',
          );

          successCount++;
        } catch (e) {
          print('Failed to send to user ${userDoc.id}: $e');
          failureCount++;
        }
      }

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Broadcast sent! Success: $successCount, Failed: $failureCount',
          ),
          backgroundColor: failureCount == 0 ? Colors.green : Colors.orange,
        ),
      );

      // Clear form if all successful
      if (failureCount == 0) {
        _messageController.clear();
        _subjectController.clear();
        setState(() {
          _selectedCategory = 'all';
          _selectedFacilities.clear();
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send broadcast: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}

// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientMessageScreen extends StatefulWidget {
  const PatientMessageScreen({super.key});

  @override
  State<PatientMessageScreen> createState() => _PatientMessageScreenState();
}

class _PatientMessageScreenState extends State<PatientMessageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Messages'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.local_hospital), text: 'CHWs'),
            Tab(icon: Icon(Icons.medical_services), text: 'Doctors'),
            Tab(icon: Icon(Icons.business), text: 'Facilities'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MessagesList(recipientType: 'chw'),
          _MessagesList(recipientType: 'doctor'),
          _MessagesList(recipientType: 'facility'),
          _MessagesList(recipientType: 'admin'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSelectRecipientDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("New Message"),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  void _showSelectRecipientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Conversation'),
        content: const Text('Choose who you would like to message:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showStartConversationDialog(context, 'chw');
            },
            child: const Text('CHW'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showStartConversationDialog(context, 'doctor');
            },
            child: const Text('Doctor'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showStartConversationDialog(context, 'facility');
            },
            child: const Text('Facility'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showStartConversationDialog(context, 'admin');
            },
            child: const Text('Admin'),
          ),
        ],
      ),
    );
  }

  void _showStartConversationDialog(BuildContext context, String recipientType) {
    showDialog(
      context: context,
      builder: (context) => _StartConversationDialog(recipientType: recipientType),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final String recipientType;
  const _MessagesList({required this.recipientType});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .where('recipientType', isEqualTo: recipientType)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final conversation = snapshot.data!.docs[index];
            final data = conversation.data() as Map<String, dynamic>;
            
            return _ConversationTile(
              conversationId: conversation.id,
              data: data,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    switch (recipientType) {
      case 'chw':
        message = 'No conversations with CHWs yet.\nStart chatting to get health support!';
        icon = Icons.local_hospital;
        color = Colors.green;
        break;
      case 'doctor':
        message = 'No conversations with doctors yet.\nConnect with medical professionals!';
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'facility':
        message = 'No conversations with facilities yet.\nContact healthcare facilities!';
        icon = Icons.business;
        color = Colors.purple;
        break;
      case 'admin':
        message = 'No conversations with admin yet.\nReach out for support!';
        icon = Icons.admin_panel_settings;
        color = Colors.orange;
        break;
      default:
        message = 'No conversations yet.';
        icon = Icons.chat;
        color = Colors.grey;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _StartConversationDialog(recipientType: recipientType),
              );
            },
            icon: const Icon(Icons.add_circle),
            label: Text('Start Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String conversationId;
  final Map<String, dynamic> data;
  final String currentUserId;

  const _ConversationTile({
    required this.conversationId,
    required this.data,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipant = (data['participants'] as List)
        .where((id) => id != currentUserId)
        .first;
    
    final lastMessage = data['lastMessage'] ?? 'No messages yet';
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final unreadCount = data['unreadCount_$currentUserId'] ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getAvatarColor(),
        child: Icon(_getAvatarIcon(), color: Colors.white),
      ),
      title: FutureBuilder<DocumentSnapshot>(
        future: _getUserInfo(otherParticipant),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Text(userData['fullName'] ?? 'Unknown User');
          }
          return Text('Loading...');
        },
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime.toDate()),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _openChatScreen(context),
    );
  }

  Future<DocumentSnapshot> _getUserInfo(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Color _getAvatarColor() {
    final recipientType = data['recipientType'] ?? '';
    switch (recipientType) {
      case 'chw':
        return Colors.green;
      case 'doctor':
        return Colors.blue;
      case 'facility':
        return Colors.purple;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAvatarIcon() {
    final recipientType = data['recipientType'] ?? '';
    switch (recipientType) {
      case 'chw':
        return Icons.local_hospital;
      case 'doctor':
        return Icons.medical_services;
      case 'facility':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _openChatScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatScreen(
          conversationId: conversationId,
          recipientType: data['recipientType'] ?? '',
        ),
      ),
    );
  }
}

class _StartConversationDialog extends StatefulWidget {
  final String recipientType;
  const _StartConversationDialog({required this.recipientType});

  @override
  State<_StartConversationDialog> createState() => _StartConversationDialogState();
}

class _StartConversationDialogState extends State<_StartConversationDialog> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Start Conversation with ${widget.recipientType.toUpperCase()}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search ${widget.recipientType}s...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildRecipientsList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildRecipientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: widget.recipientType)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No ${widget.recipientType}s found'),
          );
        }

        var docs = snapshot.data!.docs;
        
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['fullName'] ?? '';
            return name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = docs[index];
            final userData = user.data() as Map<String, dynamic>;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getAvatarColor(),
                child: Icon(_getAvatarIcon(), color: Colors.white),
              ),
              title: Text(userData['fullName'] ?? 'Unknown'),
              subtitle: Text(userData['email'] ?? ''),
              onTap: () => _startConversation(user.id, userData),
            );
          },
        );
      },
    );
  }

  Color _getAvatarColor() {
    switch (widget.recipientType) {
      case 'chw':
        return Colors.green;
      case 'doctor':
        return Colors.blue;
      case 'facility':
        return Colors.purple;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAvatarIcon() {
    switch (widget.recipientType) {
      case 'chw':
        return Icons.local_hospital;
      case 'doctor':
        return Icons.medical_services;
      case 'facility':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<void> _startConversation(String recipientId, Map<String, dynamic> recipientData) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      // Check if conversation already exists
      final existingConversation = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .get();
      
      String? conversationId;
      
      for (var doc in existingConversation.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(recipientId)) {
          conversationId = doc.id;
          break;
        }
      }
      
      // Create new conversation if none exists
      if (conversationId == null) {
        final docRef = await FirebaseFirestore.instance.collection('conversations').add({
          'participants': [currentUserId, recipientId],
          'recipientType': widget.recipientType,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': 'Conversation started',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount_$currentUserId': 0,
          'unreadCount_$recipientId': 0,
        });
        conversationId = docRef.id;
      }
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ChatScreen(
              conversationId: conversationId!,
              recipientType: widget.recipientType,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start conversation: $e')),
        );
      }
    }
  }
}

class _ChatScreen extends StatefulWidget {
  final String conversationId;
  final String recipientType;

  const _ChatScreen({
    required this.conversationId,
    required this.recipientType,
  });

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: _getAppBarColor(),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Color _getAppBarColor() {
    switch (widget.recipientType) {
      case 'chw':
        return Colors.green;
      case 'doctor':
        return Colors.blue;
      case 'facility':
        return Colors.purple;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Start the conversation by sending a message!'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final message = snapshot.data!.docs[index];
            final data = message.data() as Map<String, dynamic>;
            
            return _MessageBubble(data: data);
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            backgroundColor: _getAppBarColor(),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      // Update conversation last message
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MessageBubble({required this.data});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isMe = data['senderId'] == currentUserId;
    final timestamp = data['timestamp'] as Timestamp?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['message'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(timestamp.toDate()),
                style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

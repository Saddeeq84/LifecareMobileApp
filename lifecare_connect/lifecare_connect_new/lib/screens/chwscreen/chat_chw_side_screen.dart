import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatCHWSideScreen extends StatefulWidget {
  const ChatCHWSideScreen({super.key});

  @override
  State<ChatCHWSideScreen> createState() => _ChatCHWSideScreenState();
}

class _ChatCHWSideScreenState extends State<ChatCHWSideScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  String? selectedPatientId;
  String? selectedPatientName;
  final TextEditingController _messageController = TextEditingController();

  String getChatId(String patientId) {
    final ids = [currentUser.uid, patientId]..sort();
    return ids.join('_');
  }

  Future<List<Map<String, dynamic>>> _getAssignedPatients() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('chwId', isEqualTo: currentUser.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || selectedPatientId == null) return;

    final chatId = getChatId(selectedPatientId!);
    final message = {
      'text': _messageController.text.trim(),
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.collection('messages').add(message);
    await chatRef.set({
      'lastMessage': message['text'],
      'lastSentAt': FieldValue.serverTimestamp(),
      'participants': [currentUser.uid, selectedPatientId],
      'participantsRead': {
        selectedPatientId!: false,
        currentUser.uid: true,
      }
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  Widget _buildMessageList(String chatId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading messages'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final messages = snapshot.data!.docs;

        // Mark as read
        FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'participantsRead': {
            currentUser.uid: true,
            selectedPatientId!: false,
          },
        }, SetOptions(merge: true));

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final isMe = msg['senderId'] == currentUser.uid;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.green.shade100 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(msg['text'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Patients'),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAssignedPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Failed to load patients'));

          final patients = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Patient'),
                  value: selectedPatientId,
                  items: patients.map((p) {
                    return DropdownMenuItem<String>(
                      value: p['uid'] as String,
                      child: Text(p['fullName'] ?? 'Unnamed'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final patient = patients.firstWhere((p) => p['uid'] == value);
                    setState(() {
                      selectedPatientId = value;
                      selectedPatientName = patient['fullName'];
                    });
                  },
                ),
              ),
              if (selectedPatientId != null)
                Expanded(child: _buildMessageList(getChatId(selectedPatientId!)))
              else
                const Expanded(child: Center(child: Text('Select a patient to start chatting'))),
              if (selectedPatientId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(hintText: 'Enter message'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
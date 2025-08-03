import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatCHWScreen extends StatefulWidget {
  final String chwUid;
  final String chwName;
  const ChatCHWScreen({super.key, required this.chwUid, required this.chwName});

  @override
  State<ChatCHWScreen> createState() => _ChatCHWScreenState();
}


class _ChatCHWScreenState extends State<ChatCHWScreen> {
  final TextEditingController _controller = TextEditingController();
  late final String patientUid;
  late final String chatId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      patientUid = currentUser.uid;
      chatId = _generateChatId(patientUid, widget.chwUid);
    }
  }

  String _generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final timestamp = Timestamp.now();

    final messageRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'text': text.trim(),
      'senderId': patientUid,
      'timestamp': timestamp,
      'read': false,
    });

    // No chat metadata update needed; all messages are in 'messages' collection only.

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.chwName}"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // ✅ Mark messages as read (no chat metadata update needed)
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data()! as Map<String, dynamic>;
                    final isMine = msg['senderId'] == patientUid;

                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMine ? Colors.green.shade100 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green.shade700,
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
// Note: Ensure you have the necessary Firebase setup and dependencies in your pubspec.yaml
// to use Firebase Auth and Firestore in your Flutter project.
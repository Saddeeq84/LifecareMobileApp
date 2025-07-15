// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CHWChatScreen extends StatefulWidget {
  final String chatId; // Unique chat identifier
  final String? recipientType; // e.g., "Doctor" or "Patient"
  final String? recipientName;

  const CHWChatScreen({
    super.key,
    required this.chatId,
    this.recipientType,
    this.recipientName,
  });

  @override
  State<CHWChatScreen> createState() => _CHWChatScreenState();
}

class _CHWChatScreenState extends State<CHWChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipient = widget.recipientName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $recipient'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSentByCHW = message['sender'] == 'CHW';

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        alignment: isSentByCHW
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isSentByCHW
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSentByCHW
                                    ? Colors.teal.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              message['sender'] ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(widget.chatId);

    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      setState(() {
        _messages = List<Map<String, String>>.from(decoded);
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'text': text,
      'sender': 'CHW',
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages);
    await prefs.setString(widget.chatId, encoded);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
// Note: Ensure that the recipientType and recipientName are passed correctly
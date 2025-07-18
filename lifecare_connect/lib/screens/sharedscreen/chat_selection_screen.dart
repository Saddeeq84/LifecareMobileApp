import 'package:flutter/material.dart';

class ChatSelectionScreen extends StatelessWidget {
  const ChatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Chat'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            tileColor: Colors.teal.shade50,
            leading: const Icon(Icons.local_hospital, color: Colors.teal),
            title: const Text('Chat with Doctor'),
            onTap: () {
              Navigator.pushNamed(context, '/chw_chat_doctor');
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            tileColor: Colors.teal.shade50,
            leading: const Icon(Icons.people, color: Colors.teal),
            title: const Text('Chat with Patient'),
            onTap: () {
              Navigator.pushNamed(context, '/chw_chat_patient');
            },
          ),
        ],
      ),
    );
  }
}

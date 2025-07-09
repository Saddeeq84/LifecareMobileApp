import 'package:flutter/material.dart';

class PatientMessagesScreen extends StatelessWidget {
  const PatientMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_MessageThread> messages = [
      _MessageThread(
        chwName: 'CHW Amina Abdullahi',
        lastMessage: 'Remember to attend your next ANC visit.',
        timestamp: '2h ago',
        avatar: 'assets/images/chw1.png',
      ),
      _MessageThread(
        chwName: 'CHW Sani Bello',
        lastMessage: 'How are you feeling today?',
        timestamp: 'Yesterday',
        avatar: 'assets/images/chw2.png',
      ),
      _MessageThread(
        chwName: 'CHW Grace Okonkwo',
        lastMessage: 'I’ve updated your record.',
        timestamp: '3 days ago',
        avatar: 'assets/images/chw3.png',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final thread = messages[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(thread.avatar),
            ),
            title: Text(thread.chwName),
            subtitle: Text(
              thread.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              thread.timestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              // 🔁 Simulated: Open chat with CHW
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening chat with ${thread.chwName}')),
              );
              // In future: navigate to the ChatWithCHWScreen with pre-selected CHW
            },
          ),
        );
      },
    );
  }
}

class _MessageThread {
  final String chwName;
  final String lastMessage;
  final String timestamp;
  final String avatar;

  _MessageThread({
    required this.chwName,
    required this.lastMessage,
    required this.timestamp,
    required this.avatar,
  });
}

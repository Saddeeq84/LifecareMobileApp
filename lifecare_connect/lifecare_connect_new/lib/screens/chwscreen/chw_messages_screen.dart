import 'package:flutter/material.dart';

class CHWMessagesScreen extends StatefulWidget {
  const CHWMessagesScreen({super.key});

  @override
  State<CHWMessagesScreen> createState() => _CHWMessagesScreenState();
}

class _CHWMessagesScreenState extends State<CHWMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchTerm = ValueNotifier('');

  final List<_MessageThread> allMessages = [
    _MessageThread(
      patientName: 'Maryam Ibrahim',
      lastMessage: 'Thank you for your follow-up.',
      timestamp: '10 min ago',
      avatar: 'assets/images/patient1.png',
      unread: true,
    ),
    _MessageThread(
      patientName: 'Fatima Lawal',
      lastMessage: 'I have taken the supplements.',
      timestamp: '1h ago',
      avatar: 'assets/images/patient2.png',
      unread: false,
    ),
    _MessageThread(
      patientName: 'Rabi Usman',
      lastMessage: 'When is my next visit?',
      timestamp: '2 days ago',
      avatar: 'assets/images/patient3.png',
      unread: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchTerm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => _searchTerm.value = val,
            ),
          ),

          // 💬 Message List
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchTerm,
              builder: (context, value, _) {
                final filteredMessages = allMessages
                    .where((msg) =>
                        msg.patientName.toLowerCase().contains(value.toLowerCase()))
                    .toList();

                if (filteredMessages.isEmpty) {
                  return const Center(
                    child: Text('No matching conversations found.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final msg = filteredMessages[index];
                    return Card(
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(msg.avatar),
                            ),
                            if (msg.unread)
                              const Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(msg.patientName)),
                            if (msg.unread)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          msg.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          msg.timestamp,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening chat with ${msg.patientName}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageThread {
  final String patientName;
  final String lastMessage;
  final String timestamp;
  final String avatar;
  final bool unread;

  _MessageThread({
    required this.patientName,
    required this.lastMessage,
    required this.timestamp,
    required this.avatar,
    this.unread = false,
  });
}

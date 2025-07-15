import 'package:flutter/material.dart';

class ChatWithCHWScreen extends StatefulWidget {
  const ChatWithCHWScreen({super.key});

  @override
  State<ChatWithCHWScreen> createState() => _ChatWithCHWScreenState();
}

class _ChatWithCHWScreenState extends State<ChatWithCHWScreen> {
  final List<_CHWProfile> chwList = [
    _CHWProfile(
      name: 'CHW Amina Abdullahi',
      specialty: 'Maternal & Child Health',
      location: 'Tula Yiri, Gombe',
      avatar: 'assets/images/chw1.png',
    ),
    _CHWProfile(
      name: 'CHW Sani Bello',
      specialty: 'Nutrition',
      location: 'Kabri, Gombe',
      avatar: 'assets/images/chw2.png',
    ),
    _CHWProfile(
      name: 'CHW Grace Okonkwo',
      specialty: 'Family Planning',
      location: 'Kaltungo, Gombe',
      avatar: 'assets/images/chw3.png',
    ),
  ];

  _CHWProfile? selectedCHW;
  final TextEditingController _controller = TextEditingController();
  final Map<String, List<_ChatMessage>> chatMessages = {};

  void _openCHWProfile(_CHWProfile chw) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 250,
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(chw.avatar),
            ),
            const SizedBox(height: 10),
            Text(chw.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(chw.specialty),
            Text(chw.location, style: TextStyle(color: Colors.grey.shade700)),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Start Chat'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _startChat(chw);
              },
            )
          ],
        ),
      ),
    );
  }

  void _startChat(_CHWProfile chw) {
    setState(() {
      selectedCHW = chw;
      chatMessages.putIfAbsent(chw.name, () => []);
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && selectedCHW != null) {
      setState(() {
        chatMessages[selectedCHW!.name]!.insert(0, _ChatMessage(text: text, fromPatient: true));
      });
      _controller.clear();

      // Simulated reply
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          chatMessages[selectedCHW!.name]!.insert(
            0,
            _ChatMessage(
              text: 'Thank you. I will respond soon.',
              fromPatient: false,
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCHW == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Select a Health Worker to Chat With',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...chwList.map((chw) {
            final lastMsg = chatMessages[chw.name]?.firstOrNull?.text ?? 'No messages yet';
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage(chw.avatar)),
                title: Text(chw.name),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openCHWProfile(chw),
              ),
            );
          }),
        ],
      );
    }

    // Chat UI
    final messages = chatMessages[selectedCHW!.name]!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(selectedCHW!.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() => selectedCHW = null),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text("Start your conversation..."))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment: msg.fromPatient
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: msg.fromPatient ? Colors.green.shade100 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CHWProfile {
  final String name;
  final String specialty;
  final String location;
  final String avatar;

  _CHWProfile({
    required this.name,
    required this.specialty,
    required this.location,
    required this.avatar,
  });
}

class _ChatMessage {
  final String text;
  final bool fromPatient;

  _ChatMessage({required this.text, required this.fromPatient});
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : this[0];
}
// This code defines a chat interface for patients to communicate with community health workers (CHWs).
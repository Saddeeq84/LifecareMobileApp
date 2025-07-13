import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  final List<Map<String, String>> messages = [
    {
      "title": "Training Reminder",
      "content": "Don’t forget the CHW refresher on Monday.",
      "audience": "CHWs",
      "date": "2025-07-10"
    },
    {
      "title": "Facility Update",
      "content": "New facility added in Kabri-chan village.",
      "audience": "Doctors",
      "date": "2025-07-08"
    },
  ];

  void _openComposeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ComposeMessageForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: messages.isEmpty
          ? const Center(child: Text("No messages sent yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.message, color: Colors.deepPurple),
                    title: Text(msg["title"] ?? ""),
                    subtitle: Text("${msg["audience"]} • ${msg["date"]}"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(msg["title"] ?? ""),
                          content: Text(msg["content"] ?? ""),
                          actions: [
                            TextButton(
                              child: const Text("Close"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposeForm,
        tooltip: "Send Message",
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

class ComposeMessageForm extends StatefulWidget {
  const ComposeMessageForm({super.key});

  @override
  State<ComposeMessageForm> createState() => _ComposeMessageFormState();
}

class _ComposeMessageFormState extends State<ComposeMessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _audience = "All";

  final List<String> audiences = ["All", "CHWs", "Doctors", "Patients"];

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message sent (UI only)")),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            const Text(
              "Compose Message",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(labelText: "Message"),
                    maxLines: 4,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _audience,
                    items: audiences
                        .map((a) =>
                            DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _audience = val;
                        });
                      }
                    },
                    decoration:
                        const InputDecoration(labelText: "Target Audience"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    label: const Text("Send"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// This file defines the Admin Messages screen for the app.
// It allows admins to view sent messages and compose new ones for different audiences.
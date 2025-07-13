import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_compose_message_form.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  void _openComposeForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ComposeMessageForm(),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Message?"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );
    if (shouldDelete ?? false) {
      await FirebaseFirestore.instance.collection('adminMessages').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adminMessages')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No messages sent yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final msg = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.message, color: Colors.deepPurple),
                  title: Text(msg['title'] ?? ''),
                  subtitle: Text('${msg['audience']} • ${msg['date']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, docId),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(msg['title'] ?? ''),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['content'] ?? ''),
                            if (msg['attachmentUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Image.network(msg['attachmentUrl']),
                              ),
                          ],
                        ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openComposeForm(context),
        tooltip: "Send Message",
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

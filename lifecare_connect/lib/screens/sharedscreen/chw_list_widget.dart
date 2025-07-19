import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CHWListWidget extends StatelessWidget {
  final String viewerRole;
  final Function(DocumentSnapshot chw) onCHWTap;

  const CHWListWidget({
    super.key,
    required this.viewerRole,
    required this.onCHWTap,
  });

  @override
  Widget build(BuildContext context) {
    final chwRef = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'chw')
        .where('isApproved', isEqualTo: true) // ✅ Only approved CHWs
        .orderBy('createdAt', descending: true); // Optional: newest first

    return StreamBuilder<QuerySnapshot>(
      stream: chwRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final chwDocs = snapshot.data?.docs ?? [];
        if (chwDocs.isEmpty) {
          return const Center(child: Text("No Community Health Workers found."));
        }

        return ListView.builder(
          itemCount: chwDocs.length,
          itemBuilder: (context, index) {
            final chw = chwDocs[index];
            final data = chw.data() as Map<String, dynamic>;
            final name = data['fullName'] ?? 'Unnamed CHW';
            final phone = data['phone'] ?? 'N/A';
            final area = data['location'] ?? 'Unknown Area';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.person_pin, color: Colors.teal),
                title: Text(name),
                subtitle: Text('Area: $area\nPhone: $phone'),
                trailing: _buildTrailingIcon(context, chw),
                onTap: () => onCHWTap(chw),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildTrailingIcon(BuildContext context, DocumentSnapshot chw) {
    final name = (chw.data() as Map<String, dynamic>)['fullName'] ?? 'CHW';

    switch (viewerRole) {
      case 'admin':
        return IconButton(
          icon: const Icon(Icons.analytics_outlined, color: Colors.teal),
          tooltip: 'View Performance',
          onPressed: () => onCHWTap(chw),
        );
      case 'patient':
        return IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.teal),
          tooltip: 'Book Appointment',
          onPressed: () => onCHWTap(chw),
        );
      case 'doctor':
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'chat') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Start chat with $name')),
              );
            } else if (value == 'video') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Start video call with $name')),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'chat', child: Text('Chat')),
            const PopupMenuItem(value: 'video', child: Text('Video Call')),
          ],
        );
      default:
        return null;
    }
  }
}

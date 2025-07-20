import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffListWidget extends StatelessWidget {
  final String viewerRole;
  final String staffRole; // 'doctor' or 'chw'
  final Function(DocumentSnapshot doc) onTap;

  const StaffListWidget({
    super.key,
    required this.viewerRole,
    required this.staffRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final staffRef = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: staffRole);

    return StreamBuilder<QuerySnapshot>(
      stream: staffRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text("No ${staffRole.toUpperCase()}s found."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final name = data['fullName'] ?? 'Unnamed';
            final phone = data['phone'] ?? 'N/A';

            // Dynamic subtitle
            final subtitle = staffRole == 'doctor'
                ? 'Specialty: ${data['specialization'] ?? 'General'}'
                : 'Community: ${data['assignedCommunity'] ?? 'Unknown'}';

            final icon = staffRole == 'doctor'
                ? const Icon(Icons.local_hospital, color: Colors.teal)
                : const Icon(Icons.person, color: Colors.lightGreen);

            return Card(
              child: ListTile(
                leading: icon,
                title: Text(name),
                subtitle: Text('$subtitle\nPhone: $phone'),
                trailing: _buildActionIcon(context, doc),
                onTap: () => onTap(doc),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildActionIcon(BuildContext context, DocumentSnapshot doc) {
    final name = (doc.data() as Map<String, dynamic>)['fullName'] ?? 'Staff';

    switch (viewerRole) {
      case 'admin':
        return IconButton(
          icon: Icon(
            Icons.email,
            color: staffRole == 'doctor' ? Colors.teal : Colors.lightGreen,
          ),
          tooltip: 'Message ${staffRole.toUpperCase()}',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Messaging $name (admin flow)')),
            );
          },
        );
      default:
        return null;
    }
  }
}

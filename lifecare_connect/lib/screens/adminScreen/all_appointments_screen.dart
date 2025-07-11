// lib/screens/admin/all_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAllAppointmentsScreen extends StatefulWidget {
  const AdminAllAppointmentsScreen({super.key});

  @override
  State<AdminAllAppointmentsScreen> createState() =>
      _AdminAllAppointmentsScreenState();
}

class _AdminAllAppointmentsScreenState
    extends State<AdminAllAppointmentsScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('createdAt', descending: true);

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Appointments'),
        backgroundColor: Colors.green.shade700,
        actions: [
          DropdownButton<String>(
            value: _selectedStatus,
            dropdownColor: Colors.white,
            items: ['all', 'pending', 'booked', 'completed', 'cancelled']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatus = val);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No appointments found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(data['patientId']).get(),
                builder: (context, userSnapshot) {
                  String patientName = 'Loading...';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    patientName = userSnapshot.data!.get('name') ?? 'Unknown';
                  }

                  return ListTile(
                    title: Text('${data['type']} with ${data['doctor']}'),
                    subtitle: Text('Patient: $patientName\nReason: ${data['reason']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onSelected: (value) => _updateStatus(docId, value),
                          itemBuilder: (_) => ['pending', 'booked', 'completed', 'cancelled']
                              .map((s) => PopupMenuItem(value: s, child: Text('Set to $s')))
                              .toList(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, docId),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('appointments').doc(docId).update({'status': status});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated to $status")));
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointment deleted")));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

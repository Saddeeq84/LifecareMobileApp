// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'anc_checklist_screen.dart'; // your existing add/edit screen

class UpcomingVisitsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const UpcomingVisitsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is Timestamp) {
        final d = date.toDate();
        return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      } else if (date is DateTime) {
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } else if (date is String) {
        final d = DateTime.tryParse(date);
        if (d != null) {
          return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        }
      }
    } catch (_) {}
    return 'Invalid date';
  }

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.fromDate(DateTime.now());

    final Stream<QuerySnapshot> upcomingVisitsStream = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('anc_visits')
        .where('nextVisitDate', isGreaterThanOrEqualTo: now)
        .orderBy('nextVisitDate')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Visits - $patientName'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: upcomingVisitsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final visits = snapshot.data?.docs ?? [];

          if (visits.isEmpty) {
            return const Center(child: Text('No upcoming visits found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visits.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = visits[index];
              final visit = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  "Visit Date: ${_formatDate(visit['date'])}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Next Visit: ${_formatDate(visit['nextVisitDate'])}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ANCChecklistScreen(
                        patientId: patientId,
                        patientName: patientName,
                        visitId: doc.id,
                        initialData: visit,
                      ),
                    ),
                  );
                  if (updated == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Visit updated')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

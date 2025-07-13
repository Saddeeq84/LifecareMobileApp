import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chwScreen/upcoming_visits_screen.dart';  // import your upcoming visits screen

class ANCVisitHistoryScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const ANCVisitHistoryScreen({
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
    final visitStream = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('anc_visits')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("$patientName - ANC Visit History"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Upcoming Visits',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UpcomingVisitsScreen(
                    patientId: patientId,
                    patientName: patientName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: visitStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final visits = snapshot.data?.docs ?? [];

          if (visits.isEmpty) {
            return const Center(child: Text("No ANC/PNC visits recorded."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visits.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final visit = visits[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 Date: ${_formatDate(visit['date'])}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("🩺 BP: ${visit['bloodPressure'] ?? 'N/A'}"),
                      Text("⚖️ Weight: ${visit['weight'] ?? 'N/A'} kg"),
                      if (visit['symptoms'] != null &&
                          visit['symptoms'].toString().isNotEmpty)
                        Text("🧾 Symptoms: ${visit['symptoms']}"),
                      if (visit['medications'] != null &&
                          visit['medications'].toString().isNotEmpty)
                        Text("💊 Meds: ${visit['medications']}"),
                      if (visit['nextVisitDate'] != null)
                        Text("📆 Next Visit: ${_formatDate(visit['nextVisitDate'])}"),
                      if (visit['notes'] != null &&
                          visit['notes'].toString().isNotEmpty)
                        Text("📝 Notes: ${visit['notes']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

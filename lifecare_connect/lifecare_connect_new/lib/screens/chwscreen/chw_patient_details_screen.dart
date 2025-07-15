import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/chwscreen/anc_checklist_screen.dart';
import 'package:lifecare_connect/screens/chwscreen/anc_visit_history_screen.dart';

class CHWPatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CHWPatientDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String patientId = data['id'] ?? data['documentId'] ?? ''; // Ensure this is passed
    final String patientName = data['name'] ?? 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (data['photoUrl'] != null)
              Center(
                child: ClipOval(
                  child: Image.network(
                    data['photoUrl'],
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _detailRow("Name", patientName),
            _detailRow("Age", data['age'].toString()),
            _detailRow("Gender", data['gender'] ?? 'N/A'),
            _detailRow("Phone", data['phone'] ?? 'N/A'),
            _detailRow("Village", data['village'] ?? 'N/A'),
            _detailRow("Trimester", data['trimester'] ?? 'N/A'),
            _detailRow("Status", data['status'] ?? 'Active'),
            if (data['conditions'] != null && data['conditions'] is List && data['conditions'].isNotEmpty)
              _detailRow("Health Conditions", (data['conditions'] as List).join(', ')),
            if (data['location'] != null)
              _detailRow(
                "Location",
                "Lat: ${data['location']['latitude']}, Lng: ${data['location']['longitude']}",
              ),
            _detailRow("Registered On", _formatTimestamp(data['createdAt'])),

            const SizedBox(height: 32),

            // --- Action Buttons ---
            ElevatedButton.icon(
              icon: const Icon(Icons.checklist),
              label: const Text("Record ANC Visit"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ANCChecklistScreen(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("View Visit History"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ANCVisitHistoryScreen(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    } catch (e) {
      return 'Unknown';
    }
  }
}

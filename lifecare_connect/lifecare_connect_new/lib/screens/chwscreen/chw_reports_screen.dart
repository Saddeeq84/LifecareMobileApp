// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CHWReportsScreen extends StatelessWidget {
  const CHWReportsScreen({super.key});

  Future<Map<String, int>> _loadStats(String chwId) async {
    try {
      final patientsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('chwId', isEqualTo: chwId)
          .get();

      final patientsDocs = patientsSnapshot.docs;

      // Fetch ANC visits count for each patient
      final ancVisitCounts = await Future.wait(patientsDocs.map((doc) async {
        final ancVisitsSnapshot = await doc.reference.collection('anc_visits').get();
        return ancVisitsSnapshot.docs.length;
      }));

      final referralsSnapshot = await FirebaseFirestore.instance
          .collection('referrals')
          .where('chwId', isEqualTo: chwId)
          .get();

      return {
        'patients': patientsDocs.length,
        'ancVisits': ancVisitCounts.fold(0, (sum, count) => sum + count),
        'referrals': referralsSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error loading stats: $e');
      throw Exception('Failed to load reports data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chwId = FirebaseAuth.instance.currentUser?.uid;

    if (chwId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Reports & Analytics"),
          backgroundColor: Colors.teal,
        ),
        body: const Center(child: Text('User not authenticated. Please login.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Analytics"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadStats(chwId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data ?? {};

          if (stats.isEmpty) {
            return const Center(child: Text('No report data available.'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTile("Total Patients Registered", stats['patients'] ?? 0, Icons.people),
              _buildTile("Total ANC/PNC Visits", stats['ancVisits'] ?? 0, Icons.library_books),
              _buildTile("Total Referrals", stats['referrals'] ?? 0, Icons.local_hospital),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(String title, int count, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ),
    );
  }
}

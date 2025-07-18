import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientListScreen extends StatelessWidget {
  final String userRole;
  final Function(DocumentSnapshot patient) onPatientTap;

  const PatientListScreen({
    super.key,
    required this.userRole,
    required this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    final patientsRef = FirebaseFirestore.instance.collection('patients');

    return StreamBuilder<QuerySnapshot>(
      stream: patientsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No registered patients found."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final fullName = data['fullName'] ?? 'Unknown Name';
            final age = data['age']?.toString() ?? 'N/A';
            final gender = data['gender'] ?? 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: Text(fullName),
                subtitle: Text('Age: $age | Gender: $gender'),
                trailing: _buildTrailingButton(context, docs[index]),
                onTap: () => onPatientTap(docs[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildTrailingButton(BuildContext context, DocumentSnapshot patient) {
    final patientName = (patient.data() as Map<String, dynamic>)['fullName'] ?? 'Unknown';

    switch (userRole) {
      case 'doctor':
        return IconButton(
          icon: const Icon(Icons.note_add, color: Colors.teal),
          tooltip: 'Add Clinical Note',
          onPressed: () => onPatientTap(patient),
        );
      case 'chw':
        return IconButton(
          icon: const Icon(Icons.local_hospital, color: Colors.teal),
          tooltip: 'Document ANC',
          onPressed: () {
            // Placeholder for CHW ANC screen logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigate to ANC form for $patientName')),
            );
          },
        );
      default:
        return null;
    }
  }
}

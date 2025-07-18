import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorListWidget extends StatelessWidget {
  final String viewerRole;
  final Function(DocumentSnapshot doctor) onDoctorTap;

  const DoctorListWidget({
    super.key,
    required this.viewerRole,
    required this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    final doctorRef = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor');

    return StreamBuilder<QuerySnapshot>(
      stream: doctorRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No doctors found."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['fullName'] ?? 'Unnamed';
            final specialization = data['specialization'] ?? 'General';
            final phone = data['phone'] ?? 'N/A';

            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
                title: Text(name),
                subtitle: Text('Specialty: $specialization\nPhone: $phone'),
                trailing: _buildActionIcon(context, doc),
                onTap: () => onDoctorTap(doc),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildActionIcon(BuildContext context, DocumentSnapshot doctor) {
    final name = (doctor.data() as Map<String, dynamic>)['fullName'] ?? 'Doctor';

    switch (viewerRole) {
      case 'admin':
        return IconButton(
          icon: const Icon(Icons.email, color: Colors.teal),
          tooltip: 'Message Doctor',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Messaging $name (admin flow)')),
            );
          },
        );
      case 'patient':
        return IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.teal),
          tooltip: 'Book Appointment',
          onPressed: () => onDoctorTap(doctor),
        );
      case 'chw':
        return IconButton(
          icon: const Icon(Icons.share, color: Colors.teal),
          tooltip: 'Refer Patient',
          onPressed: () => onDoctorTap(doctor),
        );
      default:
        return null;
    }
  }
}

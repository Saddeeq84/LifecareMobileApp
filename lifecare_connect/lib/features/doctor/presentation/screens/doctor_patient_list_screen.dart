import 'package:lifecare_connect/features/chw/presentation/screens/patient_health_records_screen.dart';
// lib/screens/doctorscreen/doctor_patient_list_screen.dart

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lifecare_connect/features/doctor/presentation/screens/doctor_consultation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPatientListScreen extends StatelessWidget {
  const DoctorPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _PatientListWidget(
        userRole: 'doctor',
        onPatientTap: (DocumentSnapshot patient) {
          final patientData = patient.data() as Map<String, dynamic>;
          final patientName = patientData['name'] ?? patientData['fullName'] ?? 'Unknown Patient';

          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient ID: ${patient.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Divider(height: 32),
                  ListTile(
                    leading: const Icon(Icons.medical_services, color: Colors.teal),
                    title: const Text('Health Records'),
                    subtitle: const Text('View comprehensive health history'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigate to doctor-facing health records screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                  builder: (context) => PatientHealthRecordsScreen(
                    patientId: patient.id,
                    patientName: patientName,
                  ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.note_add, color: Colors.teal),
                    title: const Text('Add Clinical Notes'),
                    subtitle: const Text('Document consultation findings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorConsultationDetailScreen(
                            appointment: {
                              'patientId': patient.id,
                              'patientName': patientName,
                              'email': patientData['email'] ?? 'No email',
                              'phone': patientData['phone'] ?? patientData['phoneNumber'] ?? 'No phone',
                              'lastSeen': patientData['lastSeen'],
                              'isOnline': patientData['isOnline'] ?? false,
                            },
                            readOnly: false,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.teal),
                    title: const Text('Prescriptions'),
                    subtitle: const Text('Manage medications and prescriptions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorConsultationDetailScreen(
                            appointment: {
                              'patientId': patient.id,
                              'patientName': patientName,
                              'email': patientData['email'] ?? 'No email',
                              'phone': patientData['phone'] ?? patientData['phoneNumber'] ?? 'No phone',
                              'lastSeen': patientData['lastSeen'],
                              'isOnline': patientData['isOnline'] ?? false,
                            },
                            readOnly: false,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatientListWidget extends StatelessWidget {
  final String userRole;
  final Function(DocumentSnapshot) onPatientTap;

  const _PatientListWidget({
    required this.userRole,
    required this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not logged in.'));
    }

    // Fetch patients from both approved appointments and approved consultations
    return FutureBuilder<List<String>>(
      future: _getUniquePatientIds(currentUser.uid),
      builder: (context, idSnapshot) {
        if (idSnapshot.hasError) {
          return Center(child: Text('Error loading patients'));
        }
        if (idSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final patientIds = idSnapshot.data ?? [];
        if (patientIds.isEmpty) {
          return const Center(child: Text('No patients found.'));
        }
        if (patientIds.length > 10) {
          return const Center(child: Text('Too many patients to display. Please contact admin to enable batching.'));
        }
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: patientIds)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error loading patient details'));
            }
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final patients = userSnapshot.data?.docs ?? [];
            if (patients.isEmpty) {
              return const Center(child: Text('No patients found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                final data = patient.data() as Map<String, dynamic>;
                final name = data['name'] ?? data['fullName'] ?? 'Unknown Patient';
                final email = data['email'] ?? 'No email';
                final phone = data['phone'] ?? data['phoneNumber'] ?? 'No phone';
                final lastSeen = data['lastSeen'] as Timestamp?;
                final isOnline = data['isOnline'] ?? false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.teal[100],
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'P',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (!isOnline && lastSeen != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Last seen: ${_formatTimestamp(lastSeen)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_right,
                          color: Colors.teal[300],
                        ),
                        if (isOnline)
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    onTap: () => onPatientTap(patient),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<String>> _getUniquePatientIds(String doctorId) async {
    final appointmentSnaps = await FirebaseFirestore.instance
        .collection('appointments')
        .where('providerId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'approved')
        .get();
    final consultationSnaps = await FirebaseFirestore.instance
        .collection('consultations')
        .where('providerId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'approved')
        .get();
    final patientIds = <String>{};
    for (var doc in appointmentSnaps.docs) {
      final data = doc.data();
      final patientId = data['patientUid'] ?? data['patientId'];
      if (patientId != null) patientIds.add(patientId);
    }
    for (var doc in consultationSnaps.docs) {
      final data = doc.data();
      final patientId = data['patientUid'] ?? data['patientId'];
      if (patientId != null) patientIds.add(patientId);
    }
    return patientIds.toList();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
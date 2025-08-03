// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifecare_connect/features/shared/presentation/screens/messages_screen.dart';

class PatientConsultationsScreen extends StatefulWidget {
  const PatientConsultationsScreen({super.key});

  @override
  State<PatientConsultationsScreen> createState() => _PatientConsultationsScreenState();
}

class _PatientConsultationsScreenState extends State<PatientConsultationsScreen> with SingleTickerProviderStateMixin {
  // ...existing code...
  late TabController _tabController;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // Automatically run cleanup and migration after userId is set
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUserId != null) {
        await _cleanupOldMigratedRecords(context);
        await _migrateConsultationRecords(context);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _migrateConsultationRecords(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    int migratedCount = 0;
    try {
      // Migrate from consultation_records
      final consultRecords = await firestore
        .collection('consultation_records')
        .where('patientId', isEqualTo: currentUserId)
        .get();
      for (final doc in consultRecords.docs) {
        final data = doc.data();
        final healthRecordQuery = await firestore
          .collection('health_records')
          .where('patientId', isEqualTo: data['patientId'])
          .where('appointmentId', isEqualTo: data['appointmentId'])
          .get();
        if (healthRecordQuery.docs.isEmpty) {
          // Determine type: doctor or chw
          String type = 'doctor_consultation';
          if ((data['chwName'] != null && (data['chwName'] as String).isNotEmpty) || (data['providerType'] == 'CHW')) {
            type = 'chw_consultation';
          }
          await firestore.collection('health_records').add({
            ...data,
            'type': type,
            'source': 'consultation_records',
            'migratedAt': Timestamp.now(),
          });
          migratedCount++;
        }
      }
      // Migrate from consultations
      final consultations = await firestore
        .collection('consultations')
        .where('patientId', isEqualTo: currentUserId)
        .get();
      for (final doc in consultations.docs) {
        final data = doc.data();
        final healthRecordQuery = await firestore
          .collection('health_records')
          .where('patientId', isEqualTo: data['patientId'])
          .where('appointmentId', isEqualTo: data['appointmentId'])
          .get();
        if (healthRecordQuery.docs.isEmpty) {
          // Determine type: doctor or chw
          String type = 'doctor_consultation';
          if ((data['chwName'] != null && (data['chwName'] as String).isNotEmpty) || (data['providerType'] == 'CHW')) {
            type = 'chw_consultation';
          }
          await firestore.collection('health_records').add({
            ...data,
            'type': type,
            'source': 'consultations',
            'migratedAt': Timestamp.now(),
          });
          migratedCount++;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration complete! $migratedCount records copied.'), backgroundColor: Colors.blue),
      );
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your consultations')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Clean Up Old Migrated Records',
            onPressed: () async {
              await _cleanupOldMigratedRecords(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Migrate Consultation Records',
            onPressed: () async {
              await _migrateConsultationRecords(context);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingConsultations(),
          _buildCompletedConsultations(),
        ],
      ),
    );
  }

  Widget _buildPendingConsultations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data?.docs ?? [];
        if (appointments.isEmpty) {
          return const Center(child: Text('No pending consultations found'));
        }
        return FutureBuilder<List<DocumentSnapshot>>(
          future: _filterAppointmentsWithoutConsultation(appointments),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final filteredAppointments = futureSnapshot.data ?? [];
            if (filteredAppointments.isEmpty) {
              return const Center(child: Text('No pending consultations found'));
            }
            return SingleChildScrollView(
              child: Column(
                children: List.generate(filteredAppointments.length, (index) {
                  final doc = filteredAppointments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  // Format date to only show yyyy-MM-dd
                  String formattedDate = 'Unknown';
                  if (data['date'] != null && data['date'] is Timestamp) {
                    final dateObj = (data['date'] as Timestamp).toDate();
                    formattedDate = '${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}';
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                child: Icon(Icons.person, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['patientName'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('ID: ${data['patientId'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    Text('Date: $formattedDate', style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat, color: Colors.teal, size: 28),
                                tooltip: 'Text Chat',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessagesScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.videocam, color: Colors.blue, size: 28),
                                tooltip: 'Video Call',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.upcoming, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Coming Soon'),
                                        ],
                                      ),
                                      content: Text('Video call feature is under development.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('OK', style: TextStyle(color: Colors.blue)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.green, size: 28),
                                tooltip: 'Audio Call',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.upcoming, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Coming Soon'),
                                        ],
                                      ),
                                      content: Text('Audio call feature is under development.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('OK', style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                child: const Text('View Details', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                                onPressed: () async {
                                  // ...existing code...
                                  final healthRecords = await FirebaseFirestore.instance
                                    .collection('health_records')
                                    .where('patientId', isEqualTo: data['patientId'])
                                    .where('appointmentId', isEqualTo: doc.id)
                                    .get();
                                  if (healthRecords.docs.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Consultation Details'),
                                        content: const Text('No consultation notes found.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  final record = healthRecords.docs.first.data();
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Consultation Details'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (record['clinicalNotes'] != null)
                                              Text('Clinical Notes: ${record['clinicalNotes']}'),
                                            if (record['diagnosis'] != null)
                                              Text('Diagnosis: ${record['diagnosis']}'),
                                            if (record['prescriptions'] != null && (record['prescriptions'] as List).isNotEmpty)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  const Text('Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ...List<String>.from(record['prescriptions']).map((med) => Padding(
                                                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                                    child: Text(med),
                                                  )),
                                                ],
                                              ),
                                            if (record['labRequests'] != null && (record['labRequests'] as List).isNotEmpty)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  const Text('Lab Requests:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ...List<String>.from(record['labRequests']).map((lab) => Padding(
                                                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                                    child: Text(lab),
                                                  )),
                                                ],
                                              ),
                                            if (record['radiologyRequests'] != null && (record['radiologyRequests'] as List).isNotEmpty)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  const Text('Radiology Requests:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ...List<String>.from(record['radiologyRequests']).map((rad) => Padding(
                                                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                                    child: Text(rad),
                                                  )),
                                                ],
                                              ),
                                            if (record['notes'] != null)
                                              Text('Other Notes: ${record['notes']}'),
                                            if (record['nextVisit'] != null)
                                              Text('Next Visit: ${record['nextVisit']}'),
                                            if (record['ancNotes'] != null)
                                              Text('ANC Notes: ${record['ancNotes']}'),
                                            if (record['pncNotes'] != null)
                                              Text('PNC Notes: ${record['pncNotes']}'),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                  // Only call setState in widget context if needed
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                tooltip: 'Mark Complete',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Mark Consultation as Complete'),
                                      content: const Text('Are you sure you want to mark this consultation as complete?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(doc.id)
                                      .update({'status': 'completed'});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Consultation marked as complete!'), backgroundColor: Colors.green),
                                    );
                                    // Only call setState in widget context if needed
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _filterAppointmentsWithoutConsultation(List<DocumentSnapshot> appointments) async {
    List<DocumentSnapshot> result = [];
    for (final doc in appointments) {
      final data = doc.data() as Map<String, dynamic>;
      final healthRecords = await FirebaseFirestore.instance
        .collection('health_records')
        .where('patientId', isEqualTo: data['patientId'])
        .where('appointmentId', isEqualTo: doc.id)
        .get();
      if (healthRecords.docs.isEmpty) {
        result.add(doc);
      }
    }
    return result;
  }

  Widget _buildCompletedConsultations() {
    // Show consultations marked as completed
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final completedAppointments = snapshot.data?.docs ?? [];
        if (completedAppointments.isEmpty) {
          return const Center(child: Text('No completed consultations found'));
        }
        return ListView.builder(
          itemCount: completedAppointments.length,
          itemBuilder: (context, index) {
            final doc = completedAppointments[index];
            final data = doc.data() as Map<String, dynamic>;
            final providerName = data['providerName'] ?? data['doctorName'] ?? data['chwName'] ?? 'N/A';
            final dateTime = data['date'] != null ? (data['date'] as Timestamp).toDate() : null;
            final noteSummary = (data['notes'] != null && (data['notes'] as String).trim().isNotEmpty)
              ? data['notes']
              : (data['clinicalNotes'] != null && (data['clinicalNotes'] as String).trim().isNotEmpty)
                ? data['clinicalNotes']
                : '';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  '${data['patientName'] ?? 'Patient'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Provider: $providerName'),
                    Text('Date & Time: ${dateTime != null ? '${dateTime.toLocal()}' : 'Unknown'}'),
                    Text('Status: ${data['status'] ?? 'N/A'}'),
                    if (noteSummary.isNotEmpty)
                      Text('Note: $noteSummary', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Consultation Details'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Patient: ${data['patientName'] ?? 'N/A'}'),
                          Text('Provider: $providerName'),
                          Text('Date & Time: ${dateTime != null ? '${dateTime.toLocal()}' : 'Unknown'}'),
                          Text('Status: ${data['status'] ?? 'N/A'}'),
                          if (noteSummary.isNotEmpty)
                            Text('Note: $noteSummary'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
// ...existing code...

  Future<void> _cleanupOldMigratedRecords(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    int deletedCount = 0;
    try {
      final oldRecords = await firestore
        .collection('health_records')
        .where('patientId', isEqualTo: currentUserId)
        .where('source', whereIn: ['consultation_records', 'consultations'])
        .get();
      for (final doc in oldRecords.docs) {
        final data = doc.data();
        if (data['type'] == null || (data['type'] as String).isEmpty) {
          await firestore.collection('health_records').doc(doc.id).delete();
          deletedCount++;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleanup complete! $deletedCount old records deleted.'), backgroundColor: Colors.red),
      );
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleanup failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}


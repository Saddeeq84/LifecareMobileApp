import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientListScreen extends StatelessWidget {
  final String userRole;
  final Function(DocumentSnapshot patient) onPatientTap;

  const PatientListScreen({
    super.key,
    required this.userRole,
    required this.onPatientTap,
  });

  Stream<List<DocumentSnapshot>> _getPatientsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    // Role-based filtering
    switch (userRole) {
      case 'admin':
        // Admin sees all patients
        return FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .orderBy('name')
            .snapshots()
            .map((snapshot) => snapshot.docs);
      
      case 'chw':
        // CHW sees patients they created AND patients they've interacted with through health records
        return _getCHWPatientsStream(currentUser.uid);
      
      case 'doctor':
        // Doctor sees patients they've had health records with
        return _getDoctorPatientsStream(currentUser.uid);
      
      default:
        return const Stream.empty();
    }
  }

  Stream<List<DocumentSnapshot>> _getCHWPatientsStream(String chwUid) {
    // Combine multiple streams: patients created by CHW + patients with health records from CHW
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      final patientUids = <String>{};

      // Get patients from health records where CHW is involved
      try {
        final healthRecordsQuery = await FirebaseFirestore.instance
            .collection('health_records')
            .where('chwUid', isEqualTo: chwUid)
            .get();

        for (var doc in healthRecordsQuery.docs) {
          final data = doc.data();
          if (data['patientUid'] != null) {
            patientUids.add(data['patientUid']);
          }
        }
      } catch (e) {
        debugPrint('Error fetching health records for CHW: $e');
      }

      // Get patients created by this CHW
      try {
        final createdPatientsQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .where('createdBy', isEqualTo: chwUid)
            .get();

        for (var doc in createdPatientsQuery.docs) {
          patientUids.add(doc.id);
        }
      } catch (e) {
        debugPrint('Error fetching created patients for CHW: $e');
      }

      // If no patients found, return empty list
      if (patientUids.isEmpty) {
        return <DocumentSnapshot>[];
      }

      // Fetch all patient documents
      final patients = <DocumentSnapshot>[];
      final patientUidsList = patientUids.toList();

      // Firestore 'in' query limit is 10, so batch if necessary
      for (int i = 0; i < patientUidsList.length; i += 10) {
        final batch = patientUidsList.skip(i).take(10).toList();
        try {
          final batchQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'patient')
              .where(FieldPath.documentId, whereIn: batch)
              .get();
          
          patients.addAll(batchQuery.docs);
        } catch (e) {
          debugPrint('Error fetching patient batch: $e');
        }
      }

      // Sort patients by name
      patients.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>?;
        final bData = b.data() as Map<String, dynamic>?;
        final aName = aData?['name'] ?? aData?['fullName'] ?? '';
        final bName = bData?['name'] ?? bData?['fullName'] ?? '';
        return aName.compareTo(bName);
      });

      return patients;
    }).distinct();
  }

  Stream<List<DocumentSnapshot>> _getDoctorPatientsStream(String doctorUid) {
    // For doctors, get patients from health records they've accessed
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      final patientUids = <String>{};

      try {
        final healthRecordsQuery = await FirebaseFirestore.instance
            .collection('health_records')
            .where('doctorUid', isEqualTo: doctorUid)
            .get();

        for (var doc in healthRecordsQuery.docs) {
          final data = doc.data();
          if (data['patientUid'] != null) {
            patientUids.add(data['patientUid']);
          }
        }
      } catch (e) {
        debugPrint('Error fetching health records for doctor: $e');
      }

      if (patientUids.isEmpty) {
        return <DocumentSnapshot>[];
      }

      // Fetch patient documents
      final patients = <DocumentSnapshot>[];
      final patientUidsList = patientUids.toList();

      for (int i = 0; i < patientUidsList.length; i += 10) {
        final batch = patientUidsList.skip(i).take(10).toList();
        try {
          final batchQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'patient')
              .where(FieldPath.documentId, whereIn: batch)
              .get();
          
          patients.addAll(batchQuery.docs);
        } catch (e) {
          debugPrint('Error fetching patient batch for doctor: $e');
        }
      }

      return patients;
    }).distinct();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getPatientsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final fullName = data['name'] ?? data['fullName'] ?? 'Unknown Name';
            final email = data['email'] ?? 'No email';
            final phone = data['phone'] ?? 'No phone';
            final createdAt = data['createdAt'] as Timestamp?;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (email.isNotEmpty && email != 'No email')
                      Text('📧 $email', style: const TextStyle(fontSize: 12)),
                    if (phone.isNotEmpty && phone != 'No phone')
                      Text('📱 $phone', style: const TextStyle(fontSize: 12)),
                    if (createdAt != null)
                      Text(
                        'Registered: ${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: _buildTrailingButton(context, docs[index]),
                onTap: () => onPatientTap(docs[index]),
              ),
            );
          },
        );
      },
    );
  }

  String _getEmptyMessage() {
    switch (userRole) {
      case 'chw':
        return 'No patients assigned to you yet.\nStart by registering new patients.';
      case 'doctor':
        return 'No patients in your care yet.\nPatients will appear here after consultations.';
      case 'admin':
        return 'No patients registered in the system yet.';
      default:
        return 'No patients found.';
    }
  }

  Widget? _buildTrailingButton(BuildContext context, DocumentSnapshot patient) {
    final patientData = patient.data() as Map<String, dynamic>;
    final patientName = patientData['name'] ?? patientData['fullName'] ?? 'Unknown';

    switch (userRole) {
      case 'doctor':
        return IconButton(
          icon: const Icon(Icons.medical_services, color: Colors.teal),
          tooltip: 'View Health Records',
          onPressed: () => onPatientTap(patient),
        );
      case 'chw':
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.teal),
          onSelected: (value) {
            if (value == 'anc') {
              Navigator.pushNamed(context, '/anc_checklist', arguments: {
                'patientId': patient.id,
                'patientName': patientName,
              });
            } else if (value == 'records') {
              onPatientTap(patient);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'anc',
              child: Row(
                children: [
                  Icon(Icons.pregnant_woman, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('ANC Checklist'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'records',
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Health Records'),
                ],
              ),
            ),
          ],
        );
      default:
        return null;
    }
  }
}

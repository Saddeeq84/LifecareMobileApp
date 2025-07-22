import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PatientHealthRecordsScreen extends StatefulWidget {
  const PatientHealthRecordsScreen({super.key});

  @override
  State<PatientHealthRecordsScreen> createState() => _PatientHealthRecordsScreenState();
}

class _PatientHealthRecordsScreenState extends State<PatientHealthRecordsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Health Records"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUserId)
            .collection('health_records')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 24),
                  Text(
                    'No Health Records Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your consultation records and health information\nwill appear here after your visits.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final record = snapshot.data!.docs[index];
              final data = record.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getRecordTypeColor(data['type']),
                    child: Icon(
                      _getRecordTypeIcon(data['type']),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    _getRecordTypeTitle(data['type']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Provider: ${data['providerName']} (${data['providerType']})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${_formatTimestamp(data['date'])}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _viewRecordDetails(record.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRecordTypeColor(String? type) {
    switch (type) {
      case 'CONSULTATION':
        return Colors.teal;
      case 'DOCTOR_CONSULTATION':
        return Colors.indigo;
      case 'ANC_VISIT':
        return Colors.pink;
      case 'VACCINATION':
        return Colors.orange;
      case 'CHECKUP':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecordTypeIcon(String? type) {
    switch (type) {
      case 'CONSULTATION':
        return Icons.health_and_safety;
      case 'DOCTOR_CONSULTATION':
        return Icons.local_hospital;
      case 'ANC_VISIT':
        return Icons.pregnant_woman;
      case 'VACCINATION':
        return Icons.vaccines;
      case 'CHECKUP':
        return Icons.assignment;
      default:
        return Icons.medical_services;
    }
  }

  String _getRecordTypeTitle(String? type) {
    switch (type) {
      case 'CONSULTATION':
        return 'CHW Consultation';
      case 'DOCTOR_CONSULTATION':
        return 'Doctor Consultation';
      case 'ANC_VISIT':
        return 'Antenatal Care Visit';
      case 'VACCINATION':
        return 'Vaccination Record';
      case 'CHECKUP':
        return 'Health Checkup';
      default:
        return 'Medical Record';
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewRecordDetails(String recordId, Map<String, dynamic> recordData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientRecordDetailScreen(
          recordId: recordId,
          recordData: recordData,
        ),
      ),
    );
  }
}

class PatientRecordDetailScreen extends StatelessWidget {
  final String recordId;
  final Map<String, dynamic> recordData;

  const PatientRecordDetailScreen({
    super.key,
    required this.recordId,
    required this.recordData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getRecordTypeTitle(recordData['type'])),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('consultation_records')
            .doc(recordId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Record not found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final consultationDate = (data['consultationDate'] as Timestamp?)?.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Date', consultationDate != null 
                            ? '${consultationDate.day}/${consultationDate.month}/${consultationDate.year}'
                            : 'Unknown'),
                        _buildInfoRow('Provider', '${data['chwName'] ?? data['doctorName']} (${data['providerType'] ?? 'CHW'})'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Clinical Information
                if (data['chiefComplaint'] != null && data['chiefComplaint'].isNotEmpty)
                  _buildSection('Chief Complaint', data['chiefComplaint']),

                if (data['physicalExamination'] != null && data['physicalExamination'].isNotEmpty)
                  _buildSection('Physical Examination', data['physicalExamination']),

                if (data['provisionalDiagnosis'] != null && data['provisionalDiagnosis'].isNotEmpty)
                  _buildSection('Provisional Diagnosis', data['provisionalDiagnosis']),

                if (data['finalDiagnosis'] != null && data['finalDiagnosis'].isNotEmpty)
                  _buildSection('Final Diagnosis', data['finalDiagnosis']),

                // Prescriptions
                if (data['prescriptions'] != null && (data['prescriptions'] as List).isNotEmpty)
                  _buildListSection('Prescribed Medications', List<String>.from(data['prescriptions'])),

                // Laboratory Requests
                if (data['laboratoryRequests'] != null && (data['laboratoryRequests'] as List).isNotEmpty)
                  _buildListSection('Laboratory Tests Requested', List<String>.from(data['laboratoryRequests'])),

                // Radiology Requests
                if (data['radiologyRequests'] != null && (data['radiologyRequests'] as List).isNotEmpty)
                  _buildListSection('Radiology Tests Requested', List<String>.from(data['radiologyRequests'])),

                // Medical Advice
                if (data['medicalAdvice'] != null && data['medicalAdvice'].isNotEmpty)
                  _buildSection('Medical Advice', data['medicalAdvice']),

                // Special Notes (for doctor consultations)
                if (data['specialNotes'] != null && data['specialNotes'].isNotEmpty)
                  _buildSection('Special Notes', data['specialNotes']),

                // Next Visit
                if (data['nextVisit'] != null && data['nextVisit'].isNotEmpty)
                  _buildSection('Next Visit', data['nextVisit']),

                const SizedBox(height: 20),

                // Note about record access
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This medical record is for your reference only. Please consult with your healthcare provider for any questions or concerns.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getRecordTypeTitle(String? type) {
    switch (type) {
      case 'CONSULTATION':
        return 'CHW Consultation Record';
      case 'DOCTOR_CONSULTATION':
        return 'Doctor Consultation Record';
      case 'ANC_VISIT':
        return 'Antenatal Care Record';
      case 'VACCINATION':
        return 'Vaccination Record';
      case 'CHECKUP':
        return 'Health Checkup Record';
      default:
        return 'Medical Record';
    }
  }
}

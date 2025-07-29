import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHealthRecordsScreen extends StatefulWidget {
  const PatientHealthRecordsScreen({super.key});

  @override
  State<PatientHealthRecordsScreen> createState() => _PatientHealthRecordsScreenState();
}

class _PatientHealthRecordsScreenState extends State<PatientHealthRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your health records'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('health_records')
            .where('patientUid', isEqualTo: currentUserId)
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
                    _getRecordTypeTitle(data['type'], data),
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
                        'Provider: ${data['providerName'] ?? 'Unknown'} (${data['providerType'] ?? 'Unknown'})',
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
      case 'consultation':
      case 'CONSULTATION':
      case 'CHW_CONSULTATION':
        return Colors.blue;
      case 'DOCTOR_CONSULTATION':
        return Colors.purple;
      case 'ANC_VISIT':
      case 'anc_consultation':
        return Colors.pink;
      case 'pre_consultation':
      case 'PRE_CONSULTATION_CHECKLIST':
        return Colors.orange;
      case 'VACCINATION':
        return Colors.green;
      case 'CHECKUP':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecordTypeIcon(String? type) {
    switch (type) {
      case 'consultation':
      case 'CONSULTATION':
      case 'CHW_CONSULTATION':
        return Icons.medical_services;
      case 'DOCTOR_CONSULTATION':
        return Icons.local_hospital;
      case 'ANC_VISIT':
      case 'anc_consultation':
        return Icons.pregnant_woman;
      case 'pre_consultation':
      case 'PRE_CONSULTATION_CHECKLIST':
        return Icons.assignment;
      case 'VACCINATION':
        return Icons.vaccines;
      case 'CHECKUP':
        return Icons.health_and_safety;
      default:
        return Icons.medical_services;
    }
  }

  String _getRecordTypeTitle(String? type, [Map<String, dynamic>? data]) {
    switch (type) {
      case 'consultation':
        return 'Consultation Record';
      case 'CONSULTATION':
        return 'CHW Consultation';
      case 'CHW_CONSULTATION':
        return 'CHW Consultation';
      case 'DOCTOR_CONSULTATION':
        return 'Doctor Consultation';
      case 'ANC_VISIT':
      case 'anc_consultation':
        return 'Antenatal Care Visit';
      case 'pre_consultation':
      case 'PRE_CONSULTATION_CHECKLIST':
        return 'Pre-Consultation Checklist';
      case 'VACCINATION':
        return 'Vaccination Record';
      case 'CHECKUP':
        return 'Health Checkup';
      default:
        return data?['recordType'] ?? 'Medical Record';
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
      body: SingleChildScrollView(
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
                      'Record Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Date', _formatDate(recordData['date'] ?? recordData['consultationDate'])),
                    _buildInfoRow('Provider', '${recordData['providerName'] ?? 'Unknown'} (${recordData['providerType'] ?? 'Unknown'})'),
                    if (recordData['recordType'] != null)
                      _buildInfoRow('Type', recordData['recordType']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Handle different record types
            if (recordData['type'] == 'pre_consultation' || recordData['type'] == 'PRE_CONSULTATION_CHECKLIST')
              _buildPreConsultationDetails(recordData)
            else if (recordData['type'] == 'consultation' || recordData['type'] == 'anc_consultation')
              _buildConsultationDetails(recordData)
            else if (recordData['type'] == 'CHW_CONSULTATION')
              _buildCHWConsultationDetails(recordData)
            else
              _buildGenericRecordDetails(recordData),

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
      ),
    );
  }

  Widget _buildPreConsultationDetails(Map<String, dynamic> data) {
    // Extract the actual form data from different possible structures
    Map<String, dynamic> checklistData = {};
    
    // Check if data is nested under 'data' key
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      checklistData = data['data'] as Map<String, dynamic>;
    } 
    // Check if data is nested under 'formData' key
    else if (data.containsKey('formData') && data['formData'] is Map<String, dynamic>) {
      checklistData = data['formData'] as Map<String, dynamic>;
    }
    // Check if data is nested under 'preConsultation' key
    else if (data.containsKey('preConsultation') && data['preConsultation'] is Map<String, dynamic>) {
      checklistData = data['preConsultation'] as Map<String, dynamic>;
    }
    // Check if data is directly in the document
    else if (data.containsKey('reason') || 
             data.containsKey('symptoms') || 
             data.containsKey('currentMedications') ||
             data.containsKey('mainComplaint') ||
             data.containsKey('currentSymptoms')) {
      checklistData = data;
    }
    
    return Column(
      children: [
        // Enhanced field mappings with more comprehensive coverage
        if (checklistData['reason'] != null && checklistData['reason'].toString().isNotEmpty)
          _buildSection('Reason for Visit', checklistData['reason']),
        
        if (checklistData['mainComplaint'] != null && checklistData['mainComplaint'].toString().isNotEmpty)
          _buildSection('Main Complaint', checklistData['mainComplaint']),
        
        if (checklistData['symptoms'] != null && checklistData['symptoms'].toString().isNotEmpty)
          _buildSection('Current Symptoms', checklistData['symptoms']),
        
        if (checklistData['currentSymptoms'] != null && checklistData['currentSymptoms'].toString().isNotEmpty)
          _buildSection('Current Symptoms', checklistData['currentSymptoms']),
        
        if (checklistData['symptomDescription'] != null && checklistData['symptomDescription'].toString().isNotEmpty)
          _buildSection('Symptom Description', checklistData['symptomDescription']),
        
        if (checklistData['currentMedications'] != null && checklistData['currentMedications'].toString().isNotEmpty)
          _buildSection('Current Medications', checklistData['currentMedications']),
        
        if (checklistData['medications'] != null && checklistData['medications'].toString().isNotEmpty)
          _buildSection('Current Medications', checklistData['medications']),
        
        if (checklistData['allergies'] != null && checklistData['allergies'].toString().isNotEmpty)
          _buildSection('Known Allergies', checklistData['allergies']),
        
        if (checklistData['knownAllergies'] != null && checklistData['knownAllergies'].toString().isNotEmpty)
          _buildSection('Known Allergies', checklistData['knownAllergies']),
        
        if (checklistData['medicalHistory'] != null && checklistData['medicalHistory'].toString().isNotEmpty)
          _buildSection('Medical History', checklistData['medicalHistory']),
        
        if (checklistData['pastMedicalHistory'] != null && checklistData['pastMedicalHistory'].toString().isNotEmpty)
          _buildSection('Past Medical History', checklistData['pastMedicalHistory']),
        
        if (checklistData['additionalNotes'] != null && checklistData['additionalNotes'].toString().isNotEmpty)
          _buildSection('Additional Notes', checklistData['additionalNotes']),
        
        if (checklistData['notes'] != null && checklistData['notes'].toString().isNotEmpty)
          _buildSection('Additional Notes', checklistData['notes']),
        
        if (checklistData['severity'] != null && checklistData['severity'].toString().isNotEmpty)
          _buildSection('Urgency/Severity Level', checklistData['severity']),
        
        if (checklistData['urgency'] != null && checklistData['urgency'].toString().isNotEmpty)
          _buildSection('Urgency Level', checklistData['urgency']),
        
        if (checklistData['painLevel'] != null && checklistData['painLevel'].toString().isNotEmpty)
          _buildSection('Pain Level (1-10)', checklistData['painLevel']),
        
        if (checklistData['duration'] != null && checklistData['duration'].toString().isNotEmpty)
          _buildSection('Symptom Duration', checklistData['duration']),
        
        if (checklistData['emergencyContact'] != null && checklistData['emergencyContact'].toString().isNotEmpty)
          _buildSection('Emergency Contact', checklistData['emergencyContact']),
        
        if (checklistData['preferredTime'] != null && checklistData['preferredTime'].toString().isNotEmpty)
          _buildSection('Preferred Time', checklistData['preferredTime']),

        // If still no mapped items found, show all non-system fields
        if (checklistData.isEmpty) ...[
          ...data.entries
              .where((entry) => !['date', 'createdAt', 'updatedAt', 'userId', 'patientUid', 'type', 'id', 'providerId', 'providerName', 'providerType', 'accessibleBy', 'isEditable', 'isDeletable'].contains(entry.key))
              .map((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty
                  ? _buildSection(_formatFieldName(entry.key), entry.value.toString())
                  : const SizedBox.shrink())
              .toList(),
        ],
        
        if (data['requiresReview'] == true)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.pending, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This pre-consultation checklist is pending review by your healthcare provider.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCHWConsultationDetails(Map<String, dynamic> data) {
    // Extract consultation data from the 'data' field
    final consultationData = data['data'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: [
        // Symptoms
        if (consultationData['symptoms'] != null && consultationData['symptoms'].toString().isNotEmpty)
          _buildSection('Symptoms', consultationData['symptoms']),
        
        // Diagnosis
        if (consultationData['diagnosis'] != null && consultationData['diagnosis'].toString().isNotEmpty)
          _buildSection('Diagnosis', consultationData['diagnosis']),
        
        // Treatment
        if (consultationData['treatment'] != null && consultationData['treatment'].toString().isNotEmpty)
          _buildSection('Treatment', consultationData['treatment']),
        
        // Vitals
        if (consultationData['vitals'] != null && consultationData['vitals'].toString().isNotEmpty)
          _buildSection('Vital Signs', consultationData['vitals']),
        
        // Prescriptions
        if (consultationData['prescriptions'] != null && (consultationData['prescriptions'] as List).isNotEmpty)
          _buildListSection('Prescribed Medications', List<String>.from(consultationData['prescriptions'])),
        
        // Lab Requests
        if (consultationData['labRequests'] != null && (consultationData['labRequests'] as List).isNotEmpty)
          _buildListSection('Laboratory Tests Requested', List<String>.from(consultationData['labRequests'])),
        
        // Additional consultation fields
        if (consultationData['appointmentId'] != null && consultationData['appointmentId'].toString().isNotEmpty)
          _buildSection('Appointment ID', consultationData['appointmentId']),
        
        if (consultationData['consultationDate'] != null && consultationData['consultationDate'].toString().isNotEmpty)
          _buildSection('Consultation Date', consultationData['consultationDate']),
        
        // CHW Information
        if (data['providerName'] != null)
          _buildSection('Community Health Worker', data['providerName']),
        
        // If no specific fields found, show all consultation data
        if (consultationData.isEmpty || 
            (consultationData['symptoms'] == null && 
             consultationData['diagnosis'] == null && 
             consultationData['treatment'] == null)) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.entries
                      .where((entry) => !['date', 'createdAt', 'updatedAt', 'userId', 'patientUid', 'type', 'id', 'providerId', 'providerName', 'providerType', 'accessibleBy', 'isEditable', 'isDeletable'].contains(entry.key))
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildInfoRow(
                              _formatFieldName(entry.key),
                              entry.value?.toString() ?? 'N/A',
                            ),
                          )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConsultationDetails(Map<String, dynamic> data) {
    return Column(
      children: [
        // Clinical Information
        if (data['chiefComplaint'] != null && data['chiefComplaint'].toString().isNotEmpty)
          _buildSection('Chief Complaint', data['chiefComplaint']),

        if (data['physicalExamination'] != null && data['physicalExamination'].toString().isNotEmpty)
          _buildSection('Physical Examination', data['physicalExamination']),

        if (data['provisionalDiagnosis'] != null && data['provisionalDiagnosis'].toString().isNotEmpty)
          _buildSection('Provisional Diagnosis', data['provisionalDiagnosis']),

        if (data['finalDiagnosis'] != null && data['finalDiagnosis'].toString().isNotEmpty)
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
        if (data['medicalAdvice'] != null && data['medicalAdvice'].toString().isNotEmpty)
          _buildSection('Medical Advice', data['medicalAdvice']),

        // Special Notes
        if (data['specialNotes'] != null && data['specialNotes'].toString().isNotEmpty)
          _buildSection('Special Notes', data['specialNotes']),

        // Next Visit
        if (data['nextVisit'] != null && data['nextVisit'].toString().isNotEmpty)
          _buildSection('Next Visit', data['nextVisit']),

        // ANC specific fields
        if (data['type'] == 'anc_consultation') ...[
          if (data['gestationalAge'] != null)
            _buildSection('Gestational Age', '${data['gestationalAge']} weeks'),
          
          if (data['bloodPressure'] != null)
            _buildSection('Blood Pressure', data['bloodPressure']),
          
          if (data['weight'] != null)
            _buildSection('Weight', '${data['weight']} kg'),
          
          if (data['height'] != null)
            _buildSection('Height', '${data['height']} cm'),
          
          if (data['fundalHeight'] != null)
            _buildSection('Fundal Height', '${data['fundalHeight']} cm'),
          
          if (data['fetalHeartRate'] != null)
            _buildSection('Fetal Heart Rate', '${data['fetalHeartRate']} bpm'),
        ],
      ],
    );
  }

  Widget _buildGenericRecordDetails(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...data.entries
                .where((entry) => !['userId', 'patientId', 'providerId', 'providerName', 'providerType', 'date', 'createdAt', 'updatedAt', 'accessibleBy', 'isEditable', 'isDeletable'].contains(entry.key))
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildInfoRow(
                        _formatFieldName(entry.key),
                        entry.value?.toString() ?? 'N/A',
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .trim();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    
    return date.toString();
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
      case 'consultation':
        return 'Consultation Record';
      case 'CONSULTATION':
        return 'CHW Consultation Record';
      case 'CHW_CONSULTATION':
        return 'CHW Consultation Record';
      case 'DOCTOR_CONSULTATION':
        return 'Doctor Consultation Record';
      case 'ANC_VISIT':
      case 'anc_consultation':
        return 'Antenatal Care Record';
      case 'pre_consultation':
      case 'PRE_CONSULTATION_CHECKLIST':
        return 'Pre-Consultation Checklist';
      case 'VACCINATION':
        return 'Vaccination Record';
      case 'CHECKUP':
        return 'Health Checkup Record';
      default:
        return 'Medical Record';
    }
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key});

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<Map<String, dynamic>> approvedAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedAppointments();
  }

  Future<void> _loadApprovedAppointments() async {
    try {
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .orderBy('appointmentDate')
          .get();

      setState(() {
        approvedAppointments = appointmentsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading approved appointments: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Consultation"),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : approvedAppointments.isEmpty
              ? _buildNoAppointmentsView()
              : _buildAppointmentsList(),
    );
  }

  Widget _buildNoAppointmentsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'No Approved Appointments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You don\'t have any approved appointments\nready for consultation.',
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

  Widget _buildAppointmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approvedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = approvedAppointments[index];
        final appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();
        final isDue = appointmentDate.isBefore(DateTime.now().add(const Duration(hours: 1)));
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDue ? Icons.access_time : Icons.schedule,
                      color: isDue ? Colors.orange : Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDue ? 'Due for Consultation' : 'Scheduled Consultation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDue ? Colors.orange : Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Patient Details
                _buildDetailRow('Patient:', appointment['patientName'] ?? 'Unknown'),
                _buildDetailRow('Reason:', appointment['reason'] ?? 'General Consultation'),
                _buildDetailRow('Date:', _formatDateTime(appointmentDate)),
                if (appointment['referredBy'] != null)
                  _buildDetailRow('Referred by:', appointment['referredByName'] ?? 'CHW'),
                if (appointment['priority'] != null)
                  _buildDetailRow('Priority:', appointment['priority']),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Patient Info'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _viewPatientInfo(appointment),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.medical_services),
                        label: const Text('Start Consultation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _startConsultation(appointment),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _viewPatientInfo(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorPatientInfoScreen(appointment: appointment),
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorConsultationSheetScreen(appointment: appointment),
      ),
    );
  }
}

// Doctor Patient Info Screen
class DoctorPatientInfoScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const DoctorPatientInfoScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appointment['patientName'] ?? 'Patient Info'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection('appointments')
              .doc(appointment['id'])
              .get(),
          FirebaseFirestore.instance
              .collection('patients')
              .doc(appointment['patientId'])
              .collection('health_records')
              .orderBy('date', descending: true)
              .limit(1)
              .get()
              .then((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null)
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointmentDoc = snapshot.data![0] as DocumentSnapshot;
          final lastRecord = snapshot.data![1] as DocumentSnapshot?;
          
          if (!appointmentDoc.exists) {
            return const Center(child: Text('Patient information not found'));
          }

          final data = appointmentDoc.data() as Map<String, dynamic>;
          final patientInfo = data['patientInfo'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Basic Information', [
                  _buildInfoRow('Name', patientInfo['name'] ?? appointment['patientName']),
                  _buildInfoRow('Age', patientInfo['age']?.toString() ?? 'Not provided'),
                  _buildInfoRow('Sex', patientInfo['sex'] ?? 'Not provided'),
                  _buildInfoRow('Phone', patientInfo['phone'] ?? 'Not provided'),
                  _buildInfoRow('Address', patientInfo['address'] ?? 'Not provided'),
                ]),
                
                _buildSection('Current Vital Signs', [
                  _buildInfoRow('Blood Pressure', patientInfo['bloodPressure'] ?? 'Not provided'),
                  _buildInfoRow('Temperature', patientInfo['temperature'] ?? 'Not provided'),
                  _buildInfoRow('Pulse Rate', patientInfo['pulseRate'] ?? 'Not provided'),
                  _buildInfoRow('Respiratory Rate', patientInfo['respiratoryRate'] ?? 'Not provided'),
                  _buildInfoRow('Weight', patientInfo['weight'] ?? 'Not provided'),
                  _buildInfoRow('Height', patientInfo['height'] ?? 'Not provided'),
                  _buildInfoRow('BMI', patientInfo['bmi'] ?? 'Not calculated'),
                ]),
                
                _buildSection('Current Complaint', [
                  _buildInfoRow('Main Complaint', patientInfo['mainComplaint'] ?? 'Not provided'),
                  _buildInfoRow('Symptoms', patientInfo['symptoms'] ?? 'Not provided'),
                  _buildInfoRow('Duration', patientInfo['symptomDuration'] ?? 'Not provided'),
                  _buildInfoRow('Severity', patientInfo['painScale'] ?? 'Not provided'),
                ]),
                
                if (lastRecord != null) ...[
                  _buildSection('Previous Medical History', [
                    const Text('Most recent consultation record available'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _viewPreviousRecord(context, lastRecord),
                      child: const Text('View Previous Record'),
                    ),
                  ]),
                ],
                
                if (patientInfo['uploadedResults'] != null)
                  _buildSection('Uploaded Results', [
                    Text(
                      'Patient has uploaded test results for review',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Show uploaded results
                        _showUploadedResults(context, patientInfo['uploadedResults']);
                      },
                      child: const Text('View Uploaded Results'),
                    ),
                  ]),
                
                if (appointment['referredBy'] != null)
                  _buildSection('Referral Information', [
                    _buildInfoRow('Referred by', appointment['referredByName'] ?? 'CHW'),
                    _buildInfoRow('Referral reason', appointment['referralReason'] ?? 'Not provided'),
                    _buildInfoRow('Referral notes', appointment['referralNotes'] ?? 'None'),
                  ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewPreviousRecord(BuildContext context, DocumentSnapshot record) {
    // Navigate to previous record details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousRecordScreen(record: record),
      ),
    );
  }

  void _showUploadedResults(BuildContext context, dynamic uploadedResults) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uploaded Test Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uploadedResults is List && uploadedResults.isNotEmpty)
                ...uploadedResults.map<Widget>((result) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_present),
                    title: Text(result['fileName'] ?? 'Test Result'),
                    subtitle: Text(result['uploadDate'] ?? 'Date not available'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Download or view the file
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download functionality would be implemented here')),
                        );
                      },
                    ),
                  ),
                )).toList()
              else
                const Text('No uploaded results available.'),
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
  }
}

// Previous Record Screen
class PreviousRecordScreen extends StatelessWidget {
  final DocumentSnapshot record;

  const PreviousRecordScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Medical Record'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('consultation_records')
            .doc(record.id)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Record not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Record',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecordRow('Date', _formatTimestamp(data['consultationDate'])),
                        _buildRecordRow('Provider', '${data['providerName']} (${data['providerType']})'),
                        _buildRecordRow('Chief Complaint', data['chiefComplaint'] ?? ''),
                        _buildRecordRow('Physical Examination', data['physicalExamination'] ?? ''),
                        _buildRecordRow('Diagnosis', data['provisionalDiagnosis'] ?? ''),
                        if (data['finalDiagnosis'] != null && data['finalDiagnosis'].isNotEmpty)
                          _buildRecordRow('Final Diagnosis', data['finalDiagnosis']),
                        if (data['prescriptions'] != null && (data['prescriptions'] as List).isNotEmpty)
                          _buildListRow('Prescriptions', List<String>.from(data['prescriptions'])),
                        if (data['laboratoryRequests'] != null && (data['laboratoryRequests'] as List).isNotEmpty)
                          _buildListRow('Lab Requests', List<String>.from(data['laboratoryRequests'])),
                        _buildRecordRow('Medical Advice', data['medicalAdvice'] ?? ''),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 2),
            child: Text('• $item'),
          )),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Doctor Consultation Sheet Screen
class DoctorConsultationSheetScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const DoctorConsultationSheetScreen({super.key, required this.appointment});

  @override
  State<DoctorConsultationSheetScreen> createState() => _DoctorConsultationSheetScreenState();
}

class _DoctorConsultationSheetScreenState extends State<DoctorConsultationSheetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _complaintController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _surgicalHistoryController = TextEditingController();
  final _examinationController = TextEditingController();
  final _provisionalDiagnosisController = TextEditingController();
  final _finalDiagnosisController = TextEditingController();
  final _medicalAdviceController = TextEditingController();
  final _nextVisitController = TextEditingController();
  final _specialNotesController = TextEditingController();
  
  List<String> selectedLabRequests = [];
  List<String> selectedPrescriptions = [];
  List<String> selectedRadiologyRequests = [];
  
  bool isLoading = false;

  // Enhanced lists for doctors
  final List<String> labTests = [
    'Full Blood Count (FBC)',
    'Comprehensive Metabolic Panel',
    'Lipid Profile',
    'Thyroid Function Tests',
    'Liver Function Tests',
    'Kidney Function Tests',
    'Blood Sugar (Fasting & Random)',
    'HbA1c',
    'Malaria Test (RDT)',
    'HIV Test',
    'Hepatitis B & C Tests',
    'Syphilis Test (VDRL)',
    'Urine Analysis',
    'Urine Culture',
    'Stool Analysis',
    'Stool Culture',
    'Pregnancy Test',
    'Blood Group & Rhesus',
    'ESR',
    'CRP',
    'Procalcitonin',
    'Troponin',
    'D-Dimer',
    'PT/INR',
    'PTT',
  ];

  final List<String> medications = [
    'Paracetamol 500mg',
    'Ibuprofen 400mg',
    'Aspirin 75mg',
    'Amoxicillin 500mg',
    'Azithromycin 500mg',
    'Ciprofloxacin 500mg',
    'Metronidazole 400mg',
    'Doxycycline 100mg',
    'Metformin 500mg',
    'Glibenclamide 5mg',
    'Amlodipine 5mg',
    'Enalapril 10mg',
    'Hydrochlorothiazide 25mg',
    'Atorvastatin 20mg',
    'Omeprazole 20mg',
    'Salbutamol Inhaler',
    'Prednisolone 5mg',
    'Iron + Folate',
    'Multivitamins',
    'ORS Sachets',
    'Zinc Tablets',
    'Cotrimoxazole',
    'Artemether-Lumefantrine',
    'Artesunate Injectable',
  ];

  final List<String> radiologyTests = [
    'Chest X-Ray',
    'Abdominal X-Ray',
    'Pelvic X-Ray',
    'Spine X-Ray',
    'Joint X-Ray',
    'Abdominal Ultrasound',
    'Pelvic Ultrasound',
    'Obstetric Ultrasound',
    'Echocardiogram',
    'Carotid Doppler',
    'CT Scan - Head',
    'CT Scan - Chest',
    'CT Scan - Abdomen/Pelvis',
    'MRI Brain',
    'MRI Spine',
    'Mammography',
    'DEXA Scan',
    'Upper GI Series',
    'Barium Enema',
    'IVU (Intravenous Urogram)',
  ];

  @override
  void dispose() {
    _complaintController.dispose();
    _medicalHistoryController.dispose();
    _surgicalHistoryController.dispose();
    _examinationController.dispose();
    _provisionalDiagnosisController.dispose();
    _finalDiagnosisController.dispose();
    _medicalAdviceController.dispose();
    _nextVisitController.dispose();
    _specialNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Consultation Sheet'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConsultationRecord,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Basic Information (Read-only)
              _buildPatientInfoSection(),
              
              const SizedBox(height: 20),
              
              // Consultation Form
              _buildTextFormField(
                controller: _complaintController,
                label: 'Chief Complaint',
                icon: Icons.record_voice_over,
                required: true,
                maxLines: 3,
              ),
              
              _buildTextFormField(
                controller: _medicalHistoryController,
                label: 'Medical History',
                icon: Icons.history,
                maxLines: 4,
              ),
              
              _buildTextFormField(
                controller: _surgicalHistoryController,
                label: 'Surgical History',
                icon: Icons.healing,
                maxLines: 3,
              ),
              
              _buildTextFormField(
                controller: _examinationController,
                label: 'Physical Examination & Clinical Findings',
                icon: Icons.search,
                required: true,
                maxLines: 5,
                hint: 'Include vital signs, general appearance, system examination...',
              ),
              
              _buildTextFormField(
                controller: _provisionalDiagnosisController,
                label: 'Provisional Diagnosis',
                icon: Icons.assignment,
                required: true,
                maxLines: 3,
              ),
              
              _buildTextFormField(
                controller: _finalDiagnosisController,
                label: 'Final Diagnosis',
                icon: Icons.assignment_turned_in,
                maxLines: 3,
                hint: 'Can be updated after investigations',
              ),
              
              // Laboratory Requests
              _buildMultiSelectSection(
                'Laboratory Investigations',
                Icons.biotech,
                labTests,
                selectedLabRequests,
              ),
              
              // Medical Prescriptions
              _buildMultiSelectSection(
                'Medical Prescriptions',
                Icons.medication,
                medications,
                selectedPrescriptions,
              ),
              
              // Radiology Requests
              _buildMultiSelectSection(
                'Radiology Investigations',
                Icons.camera_alt,
                radiologyTests,
                selectedRadiologyRequests,
              ),
              
              _buildTextFormField(
                controller: _medicalAdviceController,
                label: 'Medical Advice & Patient Education',
                icon: Icons.lightbulb,
                maxLines: 4,
                hint: 'Include lifestyle advice, diet, follow-up instructions...',
              ),
              
              _buildTextFormField(
                controller: _specialNotesController,
                label: 'Special Notes/Observations',
                icon: Icons.note,
                maxLines: 3,
                hint: 'Any additional clinical observations or notes...',
              ),
              
              _buildTextFormField(
                controller: _nextVisitController,
                label: 'Next Visit Schedule',
                icon: Icons.event,
                hint: 'e.g., Follow-up in 2 weeks, Return if symptoms worsen',
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveConsultationRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Doctor Consultation Record',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment['id'])
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final patientInfo = data['patientInfo'] as Map<String, dynamic>? ?? {};

        return Card(
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPatientInfoRow('Name', patientInfo['name'] ?? widget.appointment['patientName']),
                          _buildPatientInfoRow('Age', patientInfo['age']?.toString() ?? 'Not provided'),
                          _buildPatientInfoRow('Sex', patientInfo['sex'] ?? 'Not provided'),
                          _buildPatientInfoRow('Main Complaint', patientInfo['mainComplaint'] ?? 'Not provided'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPatientInfoRow('BP', patientInfo['bloodPressure'] ?? 'Not recorded'),
                          _buildPatientInfoRow('Temp', patientInfo['temperature'] ?? 'Not recorded'),
                          _buildPatientInfoRow('Pulse', patientInfo['pulseRate'] ?? 'Not recorded'),
                          _buildPatientInfoRow('Weight', patientInfo['weight'] ?? 'Not recorded'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (patientInfo['symptoms'] != null)
                  _buildPatientInfoRow('Symptoms', patientInfo['symptoms']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildMultiSelectSection(
    String title,
    IconData icon,
    List<String> options,
    List<String> selectedItems,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedItems.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedItems.map((item) {
                        return Chip(
                          label: Text(item),
                          onDeleted: () {
                            setState(() {
                              selectedItems.remove(item);
                            });
                          },
                          backgroundColor: Colors.indigo.shade100,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showMultiSelectDialog(title, options, selectedItems),
                    child: Text('Add $title'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog(
    String title,
    List<String> options,
    List<String> selectedItems,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selectedItems.contains(option);
                
                return CheckboxListTile(
                  title: Text(option),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedItems.add(option);
                      } else {
                        selectedItems.remove(option);
                      }
                    });
                    Navigator.of(context).pop();
                    _showMultiSelectDialog(title, options, selectedItems);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveConsultationRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Get doctor name from user profile
      final currentUser = FirebaseAuth.instance.currentUser;
      String doctorName = 'Doctor User'; // Default fallback
      
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          doctorName = userData['name'] ?? userData['displayName'] ?? 'Doctor User';
        }
      }

      final consultationData = {
        'appointmentId': widget.appointment['id'],
        'patientId': widget.appointment['patientId'],
        'patientName': widget.appointment['patientName'],
        'doctorId': FirebaseAuth.instance.currentUser?.uid,
        'doctorName': doctorName, // Get from user profile
        'consultationDate': FieldValue.serverTimestamp(),
        'chiefComplaint': _complaintController.text.trim(),
        'medicalHistory': _medicalHistoryController.text.trim(),
        'surgicalHistory': _surgicalHistoryController.text.trim(),
        'physicalExamination': _examinationController.text.trim(),
        'provisionalDiagnosis': _provisionalDiagnosisController.text.trim(),
        'finalDiagnosis': _finalDiagnosisController.text.trim(),
        'laboratoryRequests': selectedLabRequests,
        'prescriptions': selectedPrescriptions,
        'radiologyRequests': selectedRadiologyRequests,
        'medicalAdvice': _medicalAdviceController.text.trim(),
        'specialNotes': _specialNotesController.text.trim(),
        'nextVisit': _nextVisitController.text.trim(),
        'providerType': 'DOCTOR',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save consultation record
      final docRef = await FirebaseFirestore.instance
          .collection('consultation_records')
          .add(consultationData);

      // Update appointment status
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment['id'])
          .update({
        'status': 'completed',
        'consultationRecordId': docRef.id,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Add to patient's health records
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.appointment['patientId'])
          .collection('health_records')
          .doc(docRef.id)
          .set({
        'recordRef': docRef.id,
        'type': 'DOCTOR_CONSULTATION',
        'date': FieldValue.serverTimestamp(),
        'providerId': FirebaseAuth.instance.currentUser?.uid,
        'providerName': 'Doctor User',
        'providerType': 'DOCTOR',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor consultation record saved successfully')),
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();

    } catch (e) {
      debugPrint('Error saving consultation record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving record: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}

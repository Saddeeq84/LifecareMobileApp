// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'chw_consultation_details_screen.dart';
import '../../../shared/data/services/health_records_service.dart';

class CHWConsultationScreen extends StatefulWidget {
  const CHWConsultationScreen({super.key});

  @override
  State<CHWConsultationScreen> createState() => _CHWConsultationScreenState();
}

class _CHWConsultationScreenState extends State<CHWConsultationScreen> {
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
      // List of specialized appointment types that should go to ANC consultation
      final List<String> ancAppointmentTypes = [
        'ANC (Antenatal Care)',
        'PNC (Postnatal Care)',
        'Vaccination',
        'Health Screening',
        'Mental Health Consultation',
      ];

      debugPrint('🔍 CHW Regular Consultation - Querying for: providerId=$currentUserId, status=approved');

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('providerId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .orderBy('appointmentDate')
          .get();

      debugPrint('📋 CHW Regular Consultation - Found ${appointmentsSnapshot.docs.length} total approved appointments');

      // Filter out specialized appointments - only show general consultations
      final regularAppointments = <Map<String, dynamic>>[];
      
      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        final appointmentType = data['appointmentType'] as String?;
        
        debugPrint('📝 Appointment ${doc.id}: type="$appointmentType", patient="${data['patientName']}", date="${data['appointmentDate']}"');
        
        // Only include appointments that are NOT in the specialized types
        if (appointmentType == null || !ancAppointmentTypes.contains(appointmentType)) {
          data['id'] = doc.id;
          regularAppointments.add(data);
          debugPrint('✅ Added to regular consultations: ${doc.id}');
        } else {
          debugPrint('⚠️ Filtered out (ANC type): ${doc.id}');
        }
      }

      setState(() {
        approvedAppointments = regularAppointments;
        isLoading = false;
      });

      debugPrint('📋 Loaded ${regularAppointments.length} regular consultation appointments');
      
    } catch (e) {
      debugPrint('Error loading approved appointments: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Regular Consultations"),
        backgroundColor: Colors.teal.shade700,
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
            'No Regular Consultation Appointments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You don\'t have any approved regular consultation appointments.\n\nNote: ANC, PNC, Vaccination and other specialized appointments are handled in the ANC Consultation section.',
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
                      color: isDue ? Colors.orange : Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDue ? 'Due for Consultation' : 'Scheduled Consultation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDue ? Colors.orange : Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Patient Details
                _buildDetailRow('Patient:', appointment['patientName'] ?? 'Unknown'),
                _buildDetailRow('Reason:', appointment['reason'] ?? 'General Consultation'),
                _buildDetailRow('Date:', _formatDateTime(appointmentDate)),
                if (appointment['patientPhone'] != null)
                  _buildDetailRow('Phone:', appointment['patientPhone']),
                
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
                          backgroundColor: Colors.teal,
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
            width: 80,
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
        builder: (context) => PatientInfoScreen(appointment: appointment),
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CHWConsultationDetailsScreen(
          appointmentId: appointment['id'] ?? '',
          patientId: appointment['patientId'] ?? '',
          patientName: appointment['patientName'] ?? '',
          appointmentData: appointment,
        ),
      ),
    );
  }
}

// Patient Info Screen
class PatientInfoScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const PatientInfoScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appointment['patientName'] ?? 'Patient Info'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointment['id'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Patient information not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
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
                ]),
                
                _buildSection('Vital Signs', [
                  _buildInfoRow('Blood Pressure', patientInfo['bloodPressure'] ?? 'Not provided'),
                  _buildInfoRow('Temperature', patientInfo['temperature'] ?? 'Not provided'),
                  _buildInfoRow('Pulse Rate', patientInfo['pulseRate'] ?? 'Not provided'),
                  _buildInfoRow('Weight', patientInfo['weight'] ?? 'Not provided'),
                  _buildInfoRow('Height', patientInfo['height'] ?? 'Not provided'),
                ]),
                
                _buildSection('Clinical Information', [
                  _buildInfoRow('Main Complaint', patientInfo['mainComplaint'] ?? 'Not provided'),
                  _buildInfoRow('Symptoms', patientInfo['symptoms'] ?? 'Not provided'),
                  _buildInfoRow('Duration', patientInfo['symptomDuration'] ?? 'Not provided'),
                ]),
                
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
            color: Colors.teal,
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
            width: 120,
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

// CHW Consultation Sheet Screen
class CHWConsultationSheetScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const CHWConsultationSheetScreen({super.key, required this.appointment});

  @override
  State<CHWConsultationSheetScreen> createState() => _CHWConsultationSheetScreenState();
}

class _CHWConsultationSheetScreenState extends State<CHWConsultationSheetScreen> {
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
  
  List<String> selectedLabRequests = [];
  List<String> selectedPrescriptions = [];
  List<String> selectedRadiologyRequests = [];
  
  bool isLoading = false;

  // Predefined lists
  final List<String> labTests = [
    'Full Blood Count (FBC)',
    'Blood Sugar Test',
    'Malaria Test',
    'HIV Test',
    'Hepatitis B Test',
    'Urine Analysis',
    'Stool Analysis',
    'Pregnancy Test',
    'Blood Group & Rhesus',
    'Widal Test',
  ];

  final List<String> commonDrugs = [
    'Paracetamol 500mg',
    'Amoxicillin 500mg',
    'ORS Sachets',
    'Iron Tablets',
    'Folic Acid',
    'Multivitamins',
    'Panadol Extra',
    'Cotrimoxazole',
    'Arthemeter',
    'Ibuprofen 400mg',
  ];

  final List<String> radiologyTests = [
    'Chest X-Ray',
    'Abdominal Ultrasound',
    'Pelvic Ultrasound',
    'Echocardiogram',
    'CT Scan - Head',
    'CT Scan - Chest',
    'CT Scan - Abdomen',
    'MRI Brain',
    'Mammography',
    'Bone X-Ray',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Sheet'),
        backgroundColor: Colors.teal.shade700,
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
                maxLines: 3,
              ),
              
              _buildTextFormField(
                controller: _surgicalHistoryController,
                label: 'Surgical History',
                icon: Icons.healing,
                maxLines: 2,
              ),
              
              _buildTextFormField(
                controller: _examinationController,
                label: 'Physical Examination',
                icon: Icons.search,
                required: true,
                maxLines: 4,
              ),
              
              _buildTextFormField(
                controller: _provisionalDiagnosisController,
                label: 'Provisional Diagnosis',
                icon: Icons.assignment,
                required: true,
                maxLines: 2,
              ),
              
              _buildTextFormField(
                controller: _finalDiagnosisController,
                label: 'Final Diagnosis (Optional)',
                icon: Icons.assignment_turned_in,
                maxLines: 2,
              ),
              
              // Laboratory Requests
              _buildMultiSelectSection(
                'Laboratory Requests',
                Icons.biotech,
                labTests,
                selectedLabRequests,
              ),
              
              // Medical Prescriptions
              _buildMultiSelectSection(
                'Medical Prescriptions',
                Icons.medication,
                commonDrugs,
                selectedPrescriptions,
              ),
              
              // Radiology Requests
              _buildMultiSelectSection(
                'Radiology Requests',
                Icons.camera_alt,
                radiologyTests,
                selectedRadiologyRequests,
              ),
              
              _buildTextFormField(
                controller: _medicalAdviceController,
                label: 'Medical Advice',
                icon: Icons.lightbulb,
                maxLines: 3,
              ),
              
              _buildTextFormField(
                controller: _nextVisitController,
                label: 'Next Visit (Optional)',
                icon: Icons.event,
                hint: 'e.g., Follow-up in 1 week',
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveConsultationRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Consultation Record',
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
          color: Colors.teal.shade50,
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
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPatientInfoRow('Name', patientInfo['name'] ?? widget.appointment['patientName']),
                _buildPatientInfoRow('Age', patientInfo['age']?.toString() ?? 'Not provided'),
                _buildPatientInfoRow('Sex', patientInfo['sex'] ?? 'Not provided'),
                _buildPatientInfoRow('Main Complaint', patientInfo['mainComplaint'] ?? 'Not provided'),
                _buildPatientInfoRow('Symptoms', patientInfo['symptoms'] ?? 'Not provided'),
                if (patientInfo['bloodPressure'] != null)
                  _buildPatientInfoRow('Blood Pressure', patientInfo['bloodPressure']),
                if (patientInfo['temperature'] != null)
                  _buildPatientInfoRow('Temperature', patientInfo['temperature']),
                if (patientInfo['pulseRate'] != null)
                  _buildPatientInfoRow('Pulse Rate', patientInfo['pulseRate']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
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
              Icon(icon, color: Colors.teal),
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
                          backgroundColor: Colors.teal.shade100,
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
      // Get CHW name from user profile
      final currentUser = FirebaseAuth.instance.currentUser;
      String chwName = 'CHW User'; // Default fallback
      
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          chwName = userData['name'] ?? userData['displayName'] ?? 'CHW User';
        }
      }

      final consultationData = {
        'appointmentId': widget.appointment['id'],
        'patientId': widget.appointment['patientId'],
        'patientName': widget.appointment['patientName'],
        'chwId': FirebaseAuth.instance.currentUser?.uid,
        'chwName': chwName, // Get from user profile
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
        'nextVisit': _nextVisitController.text.trim(),
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

      // Add to patient's health records using the service
      await HealthRecordsService.saveCHWConsultation(
        patientUid: widget.appointment['patientId'],
        chwUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        chwName: chwName,
        consultationData: consultationData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation record saved successfully')),
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

import 'emergency_care_screen.dart';
import 'patient_referrals_screen.dart';
// ignore_for_file: use_build_context_synchronously, avoid_print, duplicate_ignore, prefer_const_constructors, deprecated_member_use, no_leading_underscores_for_local_identifiers, use_function_type_syntax_for_parameters, non_constant_identifier_names, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:intl/intl.dart'; // Removed unused import
import 'dart:io';
// import 'patient_start_consultation_screen.dart'; // Remove unused import
import 'patient_service_request_main_screen.dart';

class MyHealthTab extends StatefulWidget {
  const MyHealthTab({super.key});

  @override
  State<MyHealthTab> createState() => _MyHealthTabState();
}

class _MyHealthTabState extends State<MyHealthTab> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _formatPreConsultationData(Map<String, dynamic> data) {
    final assessment = data['healthAssessment'] is Map<String, dynamic>
        ? data['healthAssessment'] as Map<String, dynamic>
        : data;
    final buffer = StringBuffer();
    if (assessment['mainComplaint'] != null) buffer.writeln('Main Complaint: ${assessment['mainComplaint']}');
    if (assessment['symptoms'] != null) buffer.writeln('Symptoms: ${assessment['symptoms']}');
    if (assessment['medicationsTaken'] != null) buffer.writeln('Medications: ${assessment['medicationsTaken']}');
    if (assessment['duration'] != null) buffer.writeln('Duration: ${assessment['duration']}');
    if (assessment['severity'] != null) buffer.writeln('Severity: ${assessment['severity']}');
    if (assessment['allergies'] != null) buffer.writeln('Allergies: ${assessment['allergies']}');
    if (assessment['medicalHistory'] != null) buffer.writeln('Medical History: ${assessment['medicalHistory']}');
    if (assessment['additionalNotes'] != null) buffer.writeln('Notes: ${assessment['additionalNotes']}');
    return buffer.toString().trim();
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only 2 tabs now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Health", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medical Records Card/Button
            Card(
              color: Colors.red.shade50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.medical_information, color: Colors.red.shade700),
                title: Text('Medical Records', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                subtitle: Text('View your medical records, lab results, and vital signs'),
                trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: AppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            title: const Text('Medical Records'),
                            bottom: const TabBar(
                              tabs: [
                                Tab(icon: Icon(Icons.folder), text: 'Records'),
                                Tab(icon: Icon(Icons.analytics), text: 'Lab Results'),
                              ],
                            ),
                          ),
                          body: TabBarView(
                            children: [
                              _buildMedicalRecordsTab(),
                              _buildLabResultsTab(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // My Referrals Card/Button
            Card(
              color: Colors.deepPurple.shade50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.assignment_turned_in, color: Colors.deepPurple),
                title: Text('My Referrals', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
                subtitle: Text('View and manage your referrals'),
                trailing: Icon(Icons.chevron_right, color: Colors.deepPurple),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientReferralsScreen()));
                },
              ),
            ),
            // Services Card/Button
            Card(
              color: Colors.purple.shade50,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.purple),
                title: Text('Services', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                subtitle: Text('Access health services and requests'),
                trailing: Icon(Icons.chevron_right, color: Colors.purple),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientServiceRequestMainScreen()));
                },
              ),
            ),
            // Emergency Care Card/Button
            Card(
              color: Colors.red.shade50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.emergency, color: Colors.red.shade700),
                title: Text('Emergency Care', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                subtitle: Text('Access emergency care and support'),
                trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyCareScreen()));
                },
              ),
            ),
            // ...other content if needed...
          ],
        ),
      ),
    );

  }

  // MEDICAL RECORDS TAB
  Widget _buildMedicalRecordsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_records')
                  .where(Filter.or(
                    Filter('userId', isEqualTo: currentUser!.uid),
                    Filter('patientUid', isEqualTo: currentUser!.uid),
                  ))
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final records = snapshot.data?.docs ?? [];
                if (records.isEmpty) {
                  return Center(child: Text('No medical records found'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final data = record.data() as Map<String, dynamic>;
                    // DEBUG: Print each health record to console
                    print('Health Record [{record.id}]: $data');
                    final type = data['type'] ?? '';
                    if (type == 'vital_signs') {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: const Text('Self-Reported Vital Signs'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Heart Rate: ${data['heartRate'] ?? 'N/A'} bpm'),
                              Text('Blood Pressure: ${data['bloodPressure'] ?? 'N/A'}'),
                              Text('Temperature: ${data['temperature'] ?? 'N/A'} °C'),
                              Text('Blood Sugar: ${data['bloodSugar'] ?? 'N/A'} mg/dL'),
                              Text('Weight: ${data['weight'] ?? 'N/A'} kg'),
                              Text('Height: ${data['height'] ?? 'N/A'} cm'),
                              Text('BMI: ${data['bmi'] ?? 'N/A'}'),
                              Text('Recorded: ${(data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? ''}'),
                            ],
                          ),
                        ),
                      );
                    } else if (type == 'preconsultation_checklist' || type == 'pre_consultation') {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: const Text('Pre-Consultation Checklist'),
                          subtitle: Text(
                            data['data'] != null
                              ? _formatPreConsultationData(data['data'])
                              : 'No checklist data'
                          ),
                          trailing: Text('Submitted: ${(data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? ''}'),
                        ),
                      );
                    } else if (type == 'consultation_note') {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Consultation Notes (${data['providerRole'] ?? 'Doctor/CHW'})'),
                          subtitle: Text(data['notes'] ?? 'No notes'),
                          trailing: Text('Saved: ${(data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? ''}'),
                        ),
                      );
                    } else {
                      // Default: legacy medical record
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(data['diagnosis'] ?? 'No diagnosis'),
                          subtitle: Text(data['symptoms'] ?? 'No symptoms'),
                          trailing: Text(
                            (data['createdAt'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => _viewRecordDetails(record.id, data),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewRecordDetails(String recordId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Record Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnosis: ${data['diagnosis'] ?? 'N/A'}'),
              Text('Symptoms: ${data['symptoms'] ?? 'N/A'}'),
              Text('Provider: ${data['providerName'] ?? 'N/A'}'),
              Text('Date: ${(data['createdAt'] as Timestamp?)?.toDate().toString() ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // LAB RESULTS TAB (now includes self-report vital signs and upload, both saved to health_records)
  final _vitalSignsFormKey = GlobalKey<FormState>();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Widget _buildLabResultsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lab Results & Vital Signs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadLabResult,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Lab Result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Self-Report Vital Signs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Form(
              key: _vitalSignsFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(labelText: 'Blood Pressure (e.g. 120/80)'),
                  ),
                  TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(labelText: 'Temperature (°C)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _bloodSugarController,
                    decoration: const InputDecoration(labelText: 'Blood Glucose (mg/dL)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'BMI: ${_calculateBMI(_weightController.text, _heightController.text)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final userId = currentUser!.uid;
                            await FirebaseFirestore.instance.collection('health_records').add({
                              'userId': userId,
                              'type': 'vital_signs',
                              'heartRate': _heartRateController.text,
                              'bloodPressure': _bloodPressureController.text,
                              'temperature': _temperatureController.text,
                              'bloodSugar': _bloodSugarController.text,
                              'weight': _weightController.text,
                              'height': _heightController.text,
                              'bmi': _calculateBMI(_weightController.text, _heightController.text),
                              'timestamp': Timestamp.now(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vital signs submitted!'), backgroundColor: Colors.green),
                            );
                            _heartRateController.clear();
                            _bloodPressureController.clear();
                            _temperatureController.clear();
                            _bloodSugarController.clear();
                            _weightController.clear();
                            _heightController.clear();
                            setState(() {});
                          },
                          child: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateBMI(String weight, String height) {
    try {
      final w = double.tryParse(weight);
      final h = double.tryParse(height);
      if (w != null && h != null && h > 0) {
        final bmi = w / ((h / 100) * (h / 100));
        return bmi.toStringAsFixed(1);
      }
    } catch (_) {}
    return '';
  }

  void _uploadLabResult() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final userId = currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child('lab_results/$userId/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final fileUrl = await snapshot.ref.getDownloadURL();
    // Save to health_records instead of lab_results
    await FirebaseFirestore.instance.collection('health_records').add({
      'userId': userId,
      'type': 'lab_result',
      'fileName': fileName,
      'fileUrl': fileUrl,
      'timestamp': Timestamp.now(),
      'testType': 'Lab Test',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lab result uploaded!'), backgroundColor: Colors.green),
    );
  }


  // Vital Signs tab removed; now handled in Lab Results tab

}


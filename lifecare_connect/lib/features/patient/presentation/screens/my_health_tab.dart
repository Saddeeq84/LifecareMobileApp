// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors, deprecated_member_use, no_leading_underscores_for_local_identifiers, use_function_type_syntax_for_parameters, non_constant_identifier_names, sort_child_properties_last, prefer_is_empty, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'patient_service_request_main_screen.dart';
import 'patient_referrals_screen.dart';
import 'emergency_care_screen.dart';

class _VitalSignsForm extends StatefulWidget {
  final User? currentUser;
  const _VitalSignsForm({required this.currentUser});
  @override
  State<_VitalSignsForm> createState() => _VitalSignsFormState();
}

class _VitalSignsFormState extends State<_VitalSignsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();

  String _bmi = '';
  String _bmiInterpretation = '';
  String _warning = '';

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight != null && height != null && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        _bmi = bmi.toStringAsFixed(1);
        if (bmi < 18.5) {
          _bmiInterpretation = 'Underweight';
        } else if (bmi < 25) {
          _bmiInterpretation = 'Normal';
        } else if (bmi < 30) {
          _bmiInterpretation = 'Overweight';
        } else {
          _bmiInterpretation = 'Obese';
        }
      });
    } else {
      setState(() {
        _bmi = '';
        _bmiInterpretation = '';
      });
    }
  }

  void _checkWarnings() {
    String warning = '';
    final heartRate = int.tryParse(_heartRateController.text);
    final bp = _bloodPressureController.text.split('/');
    final systolic = bp.length > 0 ? int.tryParse(bp[0]) : null;
    final diastolic = bp.length > 1 ? int.tryParse(bp[1]) : null;
    final temp = double.tryParse(_temperatureController.text);
    final sugar = double.tryParse(_bloodSugarController.text);

    if (heartRate != null && (heartRate < 50 || heartRate > 120)) {
      warning += 'Abnormal heart rate. ';
    }
    if (systolic != null && (systolic < 90 || systolic > 140)) {
      warning += 'Abnormal systolic BP. ';
    }
    if (diastolic != null && (diastolic < 60 || diastolic > 90)) {
      warning += 'Abnormal diastolic BP. ';
    }
    if (temp != null && (temp < 36.0 || temp > 37.5)) {
      warning += 'Abnormal temperature. ';
    }
    if (sugar != null && (sugar < 70 || sugar > 180)) {
      warning += 'Abnormal blood sugar. ';
    }
    setState(() {
      _warning = warning.trim();
    });
  }

  Future<void> _saveVitalSigns() async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Are you sure you want to save these vital signs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _calculateBMI();
    _checkWarnings();
    final userId = widget.currentUser?.uid;
    if (userId == null) return;
    await FirebaseFirestore.instance.collection('health_records').add({
      'userId': userId,
      'type': 'vital_signs',
      'weight': _weightController.text,
      'height': _heightController.text,
      'heartRate': _heartRateController.text,
      'bloodPressure': _bloodPressureController.text,
      'temperature': _temperatureController.text,
      'bloodSugar': _bloodSugarController.text,
      'bmi': _bmi,
      'bmiInterpretation': _bmiInterpretation,
      'warning': _warning,
      'timestamp': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vital signs saved!'), backgroundColor: Colors.green),
    );
    _formKey.currentState!.reset();
    _weightController.clear();
    _heightController.clear();
    _heartRateController.clear();
    _bloodPressureController.clear();
    _temperatureController.clear();
    _bloodSugarController.clear();
    setState(() {
      _bmi = '';
      _bmiInterpretation = '';
      _warning = '';
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _temperatureController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Your Vital Signs', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter weight' : null,
              onChanged: (_) { _calculateBMI(); _checkWarnings(); },
            ),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter height' : null,
              onChanged: (_) { _calculateBMI(); _checkWarnings(); },
            ),
            const SizedBox(height: 8),
            Text('BMI: ${_bmi.isNotEmpty ? _bmi : '-'}'),
            Text('Int: ${_bmiInterpretation.isNotEmpty ? _bmiInterpretation : '-'}'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _heartRateController,
              decoration: const InputDecoration(labelText: 'HR'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter HR' : null,
              onChanged: (_) => _checkWarnings(),
            ),
            TextFormField(
              controller: _bloodPressureController,
              decoration: const InputDecoration(labelText: 'BP'),
              keyboardType: TextInputType.text,
              validator: (v) => v == null || v.isEmpty ? 'Enter BP' : null,
              onChanged: (_) => _checkWarnings(),
            ),
            TextFormField(
              controller: _temperatureController,
              decoration: const InputDecoration(labelText: 'Temp'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter Temp' : null,
              onChanged: (_) => _checkWarnings(),
            ),
            TextFormField(
              controller: _bloodSugarController,
              decoration: const InputDecoration(labelText: 'Sugar'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter Sugar' : null,
              onChanged: (_) => _checkWarnings(),
            ),
            const SizedBox(height: 8),
            if (_warning.isNotEmpty)
              Text('Warning: $_warning', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Vital Signs'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              onPressed: _saveVitalSigns,
            ),
          ],
        ),
      ),
    );
  }
}

class MyHealthTab extends StatefulWidget {
  final String patientId;
  const MyHealthTab({super.key, required this.patientId});

  @override
  State<MyHealthTab> createState() => _MyHealthTabState();
}
class _MyHealthTabState extends State<MyHealthTab> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  // Reference to the current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;


  // Handles viewing record details (stub for now)

  // Lab Results Tab implementation (basic stub)
  Widget _buildLabResultsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lab Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          // Professional vital signs form
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _VitalSignsForm(currentUser: currentUser),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Lab Result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: _uploadLabResult,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_records')
                  .where('userId', isEqualTo: currentUser?.uid)
                  .where('type', isEqualTo: 'lab_result')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final results = snapshot.data?.docs ?? [];
                if (results.isEmpty) {
                  return Center(child: Text('No lab results found'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final data = result.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(data['fileName'] ?? 'Lab Result'),
                        subtitle: Text('Uploaded: ${(data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            final url = data['fileUrl'] as String?;
                            if (url != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(data['fileName'] ?? 'Lab Result'),
                                  content: SelectableText(url),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  late TabController _tabController;
  Widget _buildMedicalRecordsTab() {
    final debugCurrentUser = FirebaseAuth.instance.currentUser;
    debugPrint('Building MedicalRecordsTab for currentUser UID: ${debugCurrentUser?.uid}');
    debugPrint('Current widget.patientId: \'${widget.patientId}\'');
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
          // ...existing code...
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_records')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: {snapshot.error}'));
                }
                final records = snapshot.data?.docs ?? [];
                final filteredRecords = records.where((record) {
                  final data = record.data() as Map<String, dynamic>;
                  final accessibleBy = (data['accessibleBy'] is List) ? (data['accessibleBy'] as List).map((e) => e.toString().toLowerCase()).toList() : [];
                  final patientId = (data['patientId'] ?? '').toString();
                  final userId = (data['userId'] ?? '').toString();
                  final chwUid = (data['chwUid'] ?? '').toString();
                  final chwId = (data['chwId'] ?? '').toString();
                  final providerTypeRaw = (data['providerType'] ?? '').toString();
                  final providerType = providerTypeRaw.toLowerCase();
                  final nested = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : {};
                  final nestedPatientId = (nested['patientId'] ?? '').toString();
                  // Existing logic
                  final cond_accessibleBy = accessibleBy.contains('patient');
                  final cond_patientId = patientId == widget.patientId;
                  final cond_nestedPatientId = nestedPatientId == widget.patientId;
                  final cond_userId = userId == widget.patientId;
                  bool match = cond_accessibleBy || cond_patientId || cond_nestedPatientId || cond_userId;
                  // Additional logic for CHW records (case-insensitive, fallback to chwUid/chwId)
                  bool cond_isCHW = providerType.trim().toLowerCase() == 'chw' || chwUid.isNotEmpty || chwId.isNotEmpty;
                  bool cond_chwPatientMatch = patientId == widget.patientId || nestedPatientId == widget.patientId;
                  if (!match && cond_isCHW && cond_chwPatientMatch) {
                    match = true;
                  }
                  debugPrint('[RECORD RAW] id=${record.id} type=${data['type']} providerType=${data['providerType']} patientId=$patientId chwId=$chwId chwUid=$chwUid nestedPatientId=$nestedPatientId accessibleBy=$accessibleBy');
                  debugPrint('[RECORD FILTER] id=${record.id} MATCH=$match | accessibleBy=$cond_accessibleBy | patientId=$cond_patientId | nestedPatientId=$cond_nestedPatientId | userId=$cond_userId | isCHW=$cond_isCHW | chwPatientMatch=$cond_chwPatientMatch');
                  return match;
                }).toList();
                if (filteredRecords.isEmpty) {
                  return Center(child: Text('No medical records found'));
                }
                return ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    final data = record.data() as Map<String, dynamic>;
                    final rawType = data['type']?.toString() ?? '';
                    final type = rawType.toLowerCase();
                    final details = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
                    final consultationTypeRaw = (details['consultationType'] ?? data['consultationType'] ?? '').toString();
                    final typeRaw = (details['type'] ?? data['type'] ?? '').toString();
                    final consultationType = consultationTypeRaw.isNotEmpty ? consultationTypeRaw.toLowerCase() : typeRaw.toLowerCase();
                    debugPrint('[RECORD DISPLAY] id=${record.id} consultationTypeRaw=$consultationTypeRaw typeRaw=$typeRaw usedConsultationType=$consultationType');
                    // Show all records
                    String cardTitle = 'Record';
                    Color cardColor = Colors.grey.shade100;
                    final typeLower = type.toLowerCase();
                    final consultTypeLower = consultationType.toLowerCase();
                    final providerType = (data['providerType'] ?? details['providerType'] ?? '').toString().toLowerCase();
                    // --- Filter details for dialog ---
                    final filteredDetails = <String, dynamic>{};
                    for (final entry in details.entries) {
                      final k = entry.key.toLowerCase();
                      if (
                        k.contains('id') ||
                        k == 'timestamp' ||
                        k == 'statusflag' ||
                        k == 'createdat' ||
                        k == 'updatedat' ||
                        k == 'appointmentid' ||
                        k == 'patientid' ||
                        k == 'prescribedat' ||
                        k == 'requestedat'
                      ) {
                        continue;
                      }
                      filteredDetails[entry.key] = entry.value;
                    }

                    // Helper to resolve user/doctor/chw name from id
                    Future<String?> getNameFromId(String? id, String collection) async {
                      if (id == null || id.isEmpty) return null;
                      try {
                        final doc = await FirebaseFirestore.instance.collection(collection).doc(id).get();
                        if (doc.exists) {
                          final data = doc.data();
                          if (data != null && data['name'] != null) return data['name'].toString();
                          if (data != null && data['fullName'] != null) return data['fullName'].toString();
                        }
                      } catch (_) {}
                      return null;
                    }
                    final chwUidVal = (data['chwUid'] ?? details['chwUid'] ?? '').toString();
                    final chwIdVal = (data['chwId'] ?? details['chwId'] ?? '').toString();
                    final hasCHW = providerType == 'chw' || chwUidVal.isNotEmpty || chwIdVal.isNotEmpty;
                    // final appointmentType = (details['appointmentType'] ?? data['appointmentType'] ?? '').toString().toLowerCase();
                    // Vital signs
                    if (typeLower == 'vital_signs' || typeLower == 'self_reported_vitals') {
                      cardTitle = 'Self-Reported Vital Signs';
                      cardColor = Colors.white;
                    }
                    // Pre-consultation checklist
                    else if (typeLower == 'preconsultation_checklist' || typeLower == 'pre_consultation') {
                      cardTitle = 'Pre-Consultation Checklist';
                      cardColor = Colors.white;
                    }
                    // Consultation type based display logic with fallback
                    else if (consultationType.contains('general consultation')) {
                      cardTitle = 'General Consultation';
                      cardColor = Colors.blue.shade50;
                    }
                    else if (consultationType.contains('follow-up')) {
                      cardTitle = 'Follow-up Visit';
                      cardColor = Colors.blue.shade100;
                    }
                    else if (consultationType.contains('anc') || consultationType.contains('antenatal')) {
                      cardTitle = 'ANC (Antenatal Care)';
                      cardColor = Colors.green.shade100;
                    }
                    else if (consultationType.contains('pnc') || consultationType.contains('postnatal')) {
                      cardTitle = 'PNC (Postnatal Care)';
                      cardColor = Colors.green.shade200;
                    }
                    else if (consultationType.contains('emergency')) {
                      cardTitle = 'Emergency Consultation';
                      cardColor = Colors.red.shade100;
                    }
                    else if (consultationType.contains('specialist')) {
                      cardTitle = 'Specialist Referral';
                      cardColor = Colors.purple.shade100;
                    }
                    else if (consultationType.contains('screening')) {
                      cardTitle = 'Health Screening';
                      cardColor = Colors.orange.shade100;
                    }
                    else if (consultationType.contains('vaccination')) {
                      cardTitle = 'Vaccination';
                      cardColor = Colors.yellow.shade100;
                    }
                    else if (consultationType.contains('mental health')) {
                      cardTitle = 'Mental Health Consultation';
                      cardColor = Colors.teal.shade100;
                    }
                    // CHW Consultation (always show if hasCHW)
                    else if (hasCHW) {
                      debugPrint('[CHW DISPLAY] id=${record.id} hasCHW=$hasCHW consultTypeLower=$consultTypeLower typeLower=$typeLower');
                      if (consultTypeLower.contains('anc') || typeLower.contains('anc') || consultTypeLower.contains('antenatal') || typeLower.contains('antenatal')) {
                        cardTitle = 'ANC Consultation (CHW)';
                        cardColor = Colors.green.shade100;
                      } else if (consultTypeLower.contains('pnc') || typeLower.contains('pnc') || consultTypeLower.contains('postnatal') || typeLower.contains('postnatal')) {
                        cardTitle = 'PNC Consultation (CHW)';
                        cardColor = Colors.green.shade200;
                      } else if (consultTypeLower.isNotEmpty || typeLower.isNotEmpty) {
                        cardTitle = 'CHW Consultation';
                        cardColor = Colors.blue.shade100;
                      } else {
                        cardTitle = 'CHW Record';
                        cardColor = Colors.grey.shade200;
                      }
                    }
                    // Any other consultation
                    else if (typeLower.contains('consultation')) {
                      cardTitle = 'Consultation';
                      cardColor = Colors.blue.shade50;
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: cardColor,
                      child: ListTile(
                        title: Text(cardTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tap to view details'),
                        trailing: Text(
                          (data['timestamp'] is Timestamp)
                            ? (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                            : (data['createdAt'] is Timestamp)
                              ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
                              : '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              // Show all non-system fields, like doctor view
                              final map = <String, dynamic>{};
                              filteredDetails.forEach((key, value) {
                                final k = key.toLowerCase();
                                if (k == 'timestamp' || k == 'createdat' || k == 'updatedat' || k == 'appointmentid' || k == 'patientid' || k == 'prescribedat' || k == 'requestedat' || k == 'userId' || k == 'recordid' || k == 'id' || k == 'source' || k == 'status' || k == 'fileurls' || k == 'filenames' || k == 'uploadDate' || k == 'submissionTimestamp' || k == 'requiresReview' || k == 'accessibleby' || k == 'iseditable' || k == 'isdeletable') {
                                  return;
                                }
                                map[key] = value;
                              });
                              String formatLabel(String key) {
                                final k = key.toString().replaceAll('_', ' ');
                                return k.isNotEmpty ? (k[0].toUpperCase() + k.substring(1)) : k;
                              }
                              return AlertDialog(
                                title: Text(cardTitle),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...map.entries
                                          .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
                                          .map((entry) {
                                            final value = entry.value;
                                            String displayValue;
                                            if (entry.key.toLowerCase() == 'prescriptions' && value is List) {
                                              displayValue = value.map((e) {
                                                if (e is Map && e.containsKey('name')) return e['name'];
                                                return e.toString();
                                              }).join(', ');
                                            } else if (entry.key.toLowerCase() == 'laboratoryinvestigations' && value is List) {
                                              displayValue = value.map((e) {
                                                if (e is Map && e.containsKey('name')) return e['name'];
                                                return e.toString();
                                              }).join(', ');
                                            } else {
                                              displayValue = value.toString();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${formatLabel(entry.key)}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Expanded(child: Text(displayValue, style: const TextStyle(fontSize: 15))),
                                                ],
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // ...existing code...



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
  // Duplicate initState removed. Only one initState should exist in the class.

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      // If user is not logged in, show a message or login prompt
      return Center(
        child: Text('Please log in to view your health records.'),
      );
    }

    // Main widget tree for logged-in users
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Medical Record card
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.red),
              title: const Text('Medical Records'),
              subtitle: const Text('View your medical records and lab/vital signs'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.95,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) => DefaultTabController(
                      length: 2,
                      child: LayoutBuilder(
                        builder: (context, constraints) => Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                const SizedBox(width: 8),
                                const Text('Medical Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.red.shade700,
                                tabs: const [
                                  Tab(text: 'Records'),
                                  Tab(text: 'Lab/Vital Signs'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  SingleChildScrollView(
                                    controller: scrollController,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight - 60,
                                        maxHeight: constraints.maxHeight - 60,
                                      ),
                                      child: _buildMedicalRecordsTab(),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    controller: scrollController,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight - 60,
                                        maxHeight: constraints.maxHeight - 60,
                                      ),
                                      child: _buildLabResultsTab(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Services card
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services_outlined, color: Colors.red),
              title: const Text('Services'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientServiceRequestMainScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Emergency Care card
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital_outlined, color: Colors.red),
              title: const Text('Emergency Care'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyCareScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // My Referrals card
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined, color: Colors.red),
              title: const Text('My Referrals'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientReferralsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Ask AI card
          Card(
            color: Colors.grey[100],
            child: ListTile(
              leading: const Icon(Icons.smart_toy_outlined, color: Colors.blueGrey),
              title: const Text('Ask AI'),
              subtitle: const Text('Under development, coming soon!'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Ask AI'),
                    content: const Text('This feature is under development and will be available soon.'),
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
          ),
        ],
      ),
    );
  }

  // ...existing code...

  // ...existing code...

}


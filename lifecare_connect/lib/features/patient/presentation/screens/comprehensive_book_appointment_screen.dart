// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../shared/data/services/appointment_service.dart';
import '../../../shared/data/services/health_records_service.dart';
import '../../../shared/data/services/message_service.dart';

class ComprehensiveBookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? preSelectedProvider;
  
  const ComprehensiveBookAppointmentScreen({
    super.key,
    this.preSelectedProvider,
  });

  @override
  State<ComprehensiveBookAppointmentScreen> createState() => _ComprehensiveBookAppointmentScreenState();
}

class _ComprehensiveBookAppointmentScreenState extends State<ComprehensiveBookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Form Controllers
  // Main Reason for Appointment (single-select)
  final List<String> _mainReasons = [
    'Fever or Chills',
    'Cough or Breathing Difficulty',
    'Chest Pain or Palpitations',
    'Stomach Pain, Diarrhea or Constipation',
    'Urinary Problems (pain, frequency, blood in urine)',
    'Skin Rash, Itching or Swelling',
    'Headache, Seizures or Weakness',
    'Joint or Muscle Pain',
    'Mental Health Concern (e.g., Anxiety, Depression, Stress)',
    "Pregnancy or Women's Health Concern",
    "Child's Health Concern",
    'Eye or Vision Issues',
    'Ear, Nose or Throat Issues',
    'Cancer-related Concerns',
    'Other',
  ];
  String? _selectedMainReason;
  String _otherMainReason = '';
  final _symptomsController = TextEditingController();
  final _medicationsTakenController = TextEditingController();
  final _triggersController = TextEditingController();
  final _durationController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  
  // State Variables
  int _currentPage = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _providers = [];
  Map<String, dynamic>? _selectedProvider;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAppointmentType;
  String? _selectedUrgency;
  String? _selectedSeverity;
  // --- Consultation Channel ---
  String? _selectedConsultationChannel;
  final List<String> _consultationChannels = [
    'Video call',
    'Audio call',
    'Messaging chat',
    'Physical',
  ];
  
  final List<String> _appointmentTypes = [
    'General Consultation',
    'Follow-up Visit',
    'ANC (Antenatal Care)',
    'PNC (Postnatal Care)',
    'Emergency Consultation',
    'Specialist Referral',
    'Health Screening',
    'Vaccination',
    'Mental Health Consultation',
  ];
  
  final List<String> _urgencyLevels = [
    'Low - Not urgent',
    'Normal - Regular appointment',
    'High - Need attention soon',
    'Urgent - Need immediate care',
  ];
  
  final List<String> _severityScale = [
    'None - Follow-up/routine check',
    '1 - Mild discomfort',
    '2 - Noticeable but tolerable',
    '3 - Moderate discomfort',
    '4 - Significant discomfort',
    '5 - Severe pain/discomfort',
  ];

  // File upload state
  final List<File> _uploadedFiles = [];
  final List<String> _uploadedFileNames = [];

  @override
  void initState() {
    super.initState();
    
    // If a provider is pre-selected, set it and skip to the next page
    if (widget.preSelectedProvider != null) {
      _selectedProvider = widget.preSelectedProvider;
      // Skip to appointment details page (page 1)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage = 1);
      });
    } else {
      _loadProviders();
    }
  }

  @override
  void dispose() {
  // No controller for main complaint anymore
    _symptomsController.dispose();
    _medicationsTakenController.dispose();
    _triggersController.dispose();
    _durationController.dispose();
    _allergiesController.dispose();
    _medicalHistoryController.dispose();
    _emergencyContactController.dispose();
    _additionalNotesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      setState(() => _isLoading = true);
      
      print("📋 Loading providers...");
      
      final providers = <Map<String, dynamic>>[];
      
      // Get doctors with better error handling
      try {
        final doctorsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .get();
        
        print("👨‍⚕️ Found ${doctorsSnapshot.docs.length} doctors");
        
        // Add doctors
        for (var doc in doctorsSnapshot.docs) {
          final data = doc.data();
          // Check if doctor is approved (if field exists)
          final isApproved = data['isApproved'] ?? true; // Default to true if field doesn't exist
          
          if (isApproved) {
            providers.add({
              'id': doc.id,
              'name': data['fullName'] ?? data['name'] ?? 'Unknown Doctor',
              'type': 'Doctor',
              'specialization': data['specialization'] ?? 'General Practice',
              'location': data['location'] ?? 'Not specified',
              'rating': data['rating'] ?? 4.5,
              'image': data['imageUrl'] ?? data['profileImage'],
              'availability': data['availability'] ?? 'Available',
              'isApproved': isApproved,
            });
          }
        }
      } catch (e) {
        print("❌ Error loading doctors: $e");
      }
      
      // Get CHWs with better error handling  
      try {
        final chwsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'chw')
            .get();

        print("👩‍⚕️ Found ${chwsSnapshot.docs.length} CHWs");

        // Add CHWs
        for (var doc in chwsSnapshot.docs) {
          final data = doc.data();
          // CHWs don't need approval check as per the rules
          providers.add({
            'id': doc.id,
            'name': data['fullName'] ?? data['name'] ?? 'Unknown CHW',
            'type': 'Community Health Worker',
            'specialization': 'Community Health',
            'location': data['location'] ?? 'Community Center',
            'rating': data['rating'] ?? 4.0,
            'image': data['imageUrl'] ?? data['profileImage'],
            'availability': data['availability'] ?? 'Available',
            'isApproved': true,
          });
        }
      } catch (e) {
        print("❌ Error loading CHWs: $e");
      }

      print("📊 Total healthcare providers loaded: ${providers.length} (doctors & CHWs only)");

      setState(() {
        _providers = providers;
        _isLoading = false;
      });
      
      if (providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No doctors or CHWs available for appointments at the moment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("❌ Error loading providers: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading healthcare providers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _uploadedFiles.addAll(
            result.files.map((file) => File(file.path!)).toList(),
          );
          _uploadedFileNames.addAll(
            result.files.map((file) => file.name).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
      _uploadedFileNames.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      helpText: 'Select Appointment Date',
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Appointment Time',
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submitAppointment() async {
    print("🚀 Starting appointment submission...");
    
    // Only validate form if we're on the form page and form key is attached
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      print("❌ Form validation failed");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      print("❌ Date or time not selected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    if (_selectedAppointmentType == null) {
      print("❌ No appointment type selected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment type')),
      );
      return;
    }
    if (_selectedMainReason == null ||
        (_selectedMainReason == 'Other' && _otherMainReason.trim().isEmpty)) {
      print("❌ No main reason for appointment selected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or specify your main reason for appointment')),
      );
      return;
    }

    print("✅ All validation passed, proceeding with submission");
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      print("👤 User authenticated: ${currentUser.uid}");

      // Upload files to Firebase Storage
      final uploadedFileUrls = <String>[];
      print("📁 Uploading ${_uploadedFiles.length} files...");
      
      for (int i = 0; i < _uploadedFiles.length; i++) {
        final file = _uploadedFiles[i];
        final fileName = _uploadedFileNames[i];
        
        print("📤 Uploading file: $fileName");
        final ref = FirebaseStorage.instance
            .ref()
            .child('appointment_files')
            .child(currentUser.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
        
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        uploadedFileUrls.add(downloadUrl);
        print("✅ File uploaded: $fileName");
      }

      // Create appointment data
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      print("📅 Appointment scheduled for: $appointmentDateTime");

      print("💾 Appointment data prepared:");
      print("   - Patient: ${currentUser.uid}");
      print("   - Provider: ${_selectedProvider!['name']} (${_selectedProvider!['id']})");
      print("   - Type: ${_selectedAppointmentType ?? 'General Consultation'}");
      print("   - Date: $appointmentDateTime");
      print("   - Main Reason: ${_selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? ''}");

      print("💾 Saving appointment using AppointmentService...");
      
      // Get patient name for the appointment
      final patientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final patientData = patientDoc.data();
      final patientName = patientData?['name'] ?? patientData?['fullName'] ?? 'Unknown Patient';
      
      // Use AppointmentService to create appointment
      final appointmentId = await AppointmentService.createAppointment(
        patientId: currentUser.uid,
        patientName: patientName,
        providerId: _selectedProvider!['id'],
        providerName: _selectedProvider!['name'],
        providerType: _selectedProvider!['type'],
        appointmentDate: appointmentDateTime,
        reason: _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
        notes: _additionalNotesController.text.trim(),
      );

      print("✅ Appointment created with ID: $appointmentId");

      // Send notification to the provider about new appointment
      try {
        if (_selectedProvider!['type'] == 'doctor') {
          await MessageService.notifyDoctorOfNewAppointment(
            appointmentId: appointmentId,
            doctorId: _selectedProvider!['id'],
            patientName: patientName,
            appointmentDate: appointmentDateTime,
            reason: _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
          );
          print("✅ Doctor notification sent");
        } else if (_selectedProvider!['type'] == 'chw') {
          await MessageService.notifyChwOfNewAppointment(
            appointmentId: appointmentId,
            chwId: _selectedProvider!['id'],
            patientName: patientName,
            appointmentDate: appointmentDateTime,
            reason: _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
          );
          print("✅ CHW notification sent");
        }
      } catch (notificationError) {
        print("⚠️ Failed to send notification: $notificationError");
        // Don't fail the appointment creation if notification fails
      }

      // Update the appointment with additional data from the comprehensive form
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'appointmentType': _selectedAppointmentType ?? 'General Consultation',
        'urgency': _selectedUrgency ?? 'Normal - Regular appointment',
        'consultationChannel': _selectedConsultationChannel ?? 'Chat Messaging',
        'patientUid': currentUser.uid, // Add for consistency with health records
        
        // Pre-consultation checklist
        'preConsultationData': {
          'mainComplaint': _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
          'symptoms': _symptomsController.text.trim(),
          'medicationsTaken': _medicationsTakenController.text.trim(),
          'triggers': _triggersController.text.trim(),
          'duration': _durationController.text.trim(),
          'severity': _selectedSeverity ?? '1 - Mild discomfort',
          'allergies': _allergiesController.text.trim(),
          'medicalHistory': _medicalHistoryController.text.trim(),
          'emergencyContact': _emergencyContactController.text.trim(),
          'additionalNotes': _additionalNotesController.text.trim(),
          'uploadedFiles': uploadedFileUrls,
          'uploadedFileNames': _uploadedFileNames,
        },
        
        // Payment info (inactive)
        'paymentMethod': 'pending',
        'paymentStatus': 'not_required',
        'amount': 0,
      });

      print("✅ Appointment updated with comprehensive data");

      // Save comprehensive pre-consultation checklist to health records
        print("📋 Saving pre-consultation checklist to health records...");
        final preConsultationData = {
          'appointmentId': appointmentId,
          'appointmentType': _selectedAppointmentType ?? 'General Consultation',
          'urgency': _selectedUrgency ?? 'Normal - Regular appointment',
          'providerName': _selectedProvider!['name'],
          'providerType': _selectedProvider!['type'],
          'appointmentDate': DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          ).toIso8601String(),
          'healthAssessment': {
            'mainComplaint': _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
            'symptoms': _symptomsController.text.trim(),
            'medicationsTaken': _medicationsTakenController.text.trim(),
            'triggers': _triggersController.text.trim(),
            'duration': _durationController.text.trim(),
            'severity': _selectedSeverity ?? '1 - Mild discomfort',
            'allergies': _allergiesController.text.trim(),
            'medicalHistory': _medicalHistoryController.text.trim(),
            'emergencyContact': _emergencyContactController.text.trim(),
            'additionalNotes': _additionalNotesController.text.trim(),
          },
          'attachments': {
            'fileUrls': uploadedFileUrls,
            'fileNames': _uploadedFileNames,
            'uploadDate': DateTime.now().toIso8601String(),
          },
          'source': 'patient_mobile_app',
          'submissionTimestamp': DateTime.now().toIso8601String(),
        };

        // Save to health_records for My Health tab
        await FirebaseFirestore.instance.collection('health_records').add({
          'userId': currentUser.uid,
          'type': 'preconsultation_checklist',
          'data': preConsultationData,
          'timestamp': Timestamp.now(),
        });

        await HealthRecordsService.savePreConsultationChecklist(
          patientUid: currentUser.uid,
          patientName: patientName,
          checklistData: preConsultationData,
        );

        print("✅ Pre-consultation checklist saved to health records successfully");

        // Add entry to patient health timeline
        print("📈 Adding to health timeline...");
        await FirebaseFirestore.instance
            .collection('health_timeline')
            .add({
          'patientId': currentUser.uid,
          'eventType': 'pre_consultation_assessment',
          'title': 'Pre-Consultation Assessment Completed',
          'description': 'Comprehensive health assessment submitted for ${_selectedProvider!['name']} appointment',
          'eventDate': FieldValue.serverTimestamp(),
          'appointmentId': appointmentId,
          'providerId': _selectedProvider!['id'],
          'providerName': _selectedProvider!['name'],
          'providerType': _selectedProvider!['type'],
          'mainComplaint': _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
          'severity': _selectedSeverity ?? '1 - Mild discomfort',
          'urgency': _selectedUrgency ?? 'Normal - Regular appointment',
          'hasAttachments': uploadedFileUrls.isNotEmpty,
          'attachmentCount': uploadedFileUrls.length,
          'status': 'submitted',
          'category': 'assessment',
          'source': 'patient_mobile_app',
        });

        print("✅ Health timeline entry created successfully");

        // Update patient health summary with latest information
        print("📊 Updating health summary...");
        final healthSummaryRef = FirebaseFirestore.instance
            .collection('health_summaries')
            .doc(currentUser.uid);
        
        final healthSummaryDoc = await healthSummaryRef.get();
        
        if (healthSummaryDoc.exists) {
          // Update existing health summary
          await healthSummaryRef.update({
            'lastAssessmentDate': FieldValue.serverTimestamp(),
            'lastComplaint': _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
            'lastSymptoms': _symptomsController.text.trim(),
            'currentMedications': _medicationsTakenController.text.trim(),
            'knownAllergies': _allergiesController.text.trim(),
            'lastSeverityReported': _selectedSeverity ?? '1 - Mild discomfort',
            'lastProviderSeen': _selectedProvider!['name'],
            'lastProviderType': _selectedProvider!['type'],
            'assessmentCount': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
            'hasRecentSymptoms': _symptomsController.text.trim().isNotEmpty,
            'hasKnownAllergies': _allergiesController.text.trim().isNotEmpty,
            'onMedications': _medicationsTakenController.text.trim().isNotEmpty,
          });
        } else {
          // Create new health summary
          await healthSummaryRef.set({
            'patientId': currentUser.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'lastAssessmentDate': FieldValue.serverTimestamp(),
            'lastComplaint': _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? '',
            'lastSymptoms': _symptomsController.text.trim(),
            'currentMedications': _medicationsTakenController.text.trim(),
            'knownAllergies': _allergiesController.text.trim(),
            'medicalHistory': _medicalHistoryController.text.trim(),
            'emergencyContact': _emergencyContactController.text.trim(),
            'lastSeverityReported': _selectedSeverity ?? '1 - Mild discomfort',
            'lastProviderSeen': _selectedProvider!['name'],
            'lastProviderType': _selectedProvider!['type'],
            'assessmentCount': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'hasRecentSymptoms': _symptomsController.text.trim().isNotEmpty,
            'hasKnownAllergies': _allergiesController.text.trim().isNotEmpty,
            'onMedications': _medicationsTakenController.text.trim().isNotEmpty,
            'profileComplete': true,
          });
        }

        print("✅ Health summary updated successfully");

        if (mounted) {
          setState(() => _isLoading = false);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Appointment request submitted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          print("🎉 Appointment submission completed successfully!");

          // Navigate back
          Navigator.of(context).pop();
        }

    } catch (e) {
      print("💥 Error during appointment submission: $e");
      print("💥 Error type: ${e.runtimeType}");
      if (e.toString().contains('permission')) {
        print("🔒 Firebase permission error detected");
      }
      if (mounted) {
        setState(() => _isLoading = false);
        
        String errorMessage = 'Error submitting appointment';
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please contact support.';
        } else if (e.toString().contains('invalid')) {
          errorMessage = 'Invalid data. Please check your inputs and try again.';
        } else {
          errorMessage = 'Error submitting appointment: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentPage 
                          ? Colors.teal.shade700 
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildProviderSelectionPage(),
                _buildPreConsultationChecklistPage(),
                _buildDateTimeSelectionPage(),
                _buildReviewAndSubmitPage(),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
    onPressed: _isLoading ? null : () {
      if (_currentPage < 3) {
        _nextPage();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Appointment Submission'),
            content: const Text('Are you sure you want to submit this appointment request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Show confirmation message before actual submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Submitting appointment request...'),
                      backgroundColor: Colors.teal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _submitAppointment();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      }
    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_currentPage < 3 ? 'Next' : 'Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Doctor or CHW',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose from available doctors and community health workers for your appointment',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For facility services (labs, scans, pharmacy), please use the Service Request option',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading healthcare providers...')
                ],
              ),
            )
          else if (_providers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.info, size: 48, color: Colors.orange.shade700),
                  const SizedBox(height: 16),
                  Text(
                    'No Providers Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No healthcare providers are currently available for booking. Please try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange.shade600),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                final isSelected = _selectedProvider?['id'] == provider['id'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.teal : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? Colors.teal.shade50 : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedProvider = provider;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Provider Avatar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal.shade100,
                              border: Border.all(
                                color: isSelected ? Colors.teal : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: provider['image'] != null 
                                ? ClipOval(
                                    child: Image.network(
                                      provider['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                          _buildProviderIcon(provider['type']),
                                    ),
                                  )
                                : _buildProviderIcon(provider['type']),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Provider Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? Colors.teal.shade800 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getProviderTypeColor(provider['type']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    provider['type'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  provider['specialization'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, 
                                         size: 14, 
                                         color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        provider['location'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, 
                                         size: 14, 
                                         color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider['rating'].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        provider['availability'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Selection Indicator
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPreConsultationChecklistPage() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pre-Consultation Checklist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide detailed information to help your healthcare provider prepare for your consultation',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Main Reason for Appointment (single-select)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Main Reason for Appointment *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the main symptom or reason for consultation (Choose the most relevant one).',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ..._mainReasons.map((reason) {
                  if (reason == 'Other') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<String>(
                          title: const Text('Other (please specify):'),
                          value: 'Other',
                          groupValue: _selectedMainReason,
                          onChanged: (val) {
                            setState(() {
                              _selectedMainReason = val;
                              _otherMainReason = '';
                            });
                          },
                        ),
                        if (_selectedMainReason == 'Other')
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0, bottom: 8),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Please specify',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => setState(() => _otherMainReason = val),
                              validator: (val) {
                                if (_selectedMainReason == 'Other' && (val == null || val.trim().isEmpty)) {
                                  return 'Please specify your main reason';
                                }
                                return null;
                              },
                            ),
                          ),
                      ],
                    );
                  }
                  return RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: _selectedMainReason,
                    onChanged: (val) {
                      setState(() {
                        _selectedMainReason = val;
                        if (val != 'Other') _otherMainReason = '';
                      });
                    },
                  );
                }),
                if (_selectedMainReason == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4),
                    child: Text('Please select a main reason', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                const SizedBox(height: 16),
              ],
            ),
            
            // Symptoms
            _buildTextFormField(
              controller: _symptomsController,
              label: 'Current Symptoms',
              hint: 'List all symptoms you are experiencing',
              maxLines: 3,
            ),
            
            // Duration
            _buildTextFormField(
              controller: _durationController,
              label: 'Duration of Symptoms',
              hint: 'How long have you been experiencing these symptoms?',
            ),
            
            // Severity
            _buildDropdownField(
              label: 'Severity Level',
              value: _selectedSeverity,
              items: _severityScale,
              onChanged: (value) => setState(() => _selectedSeverity = value),
            ),
            
            // Medications Taken
            _buildTextFormField(
              controller: _medicationsTakenController,
              label: 'Current Medications',
              hint: 'List any medications you are currently taking or have taken recently',
              maxLines: 2,
            ),
            
            // Triggers
            _buildTextFormField(
              controller: _triggersController,
              label: 'Triggers / What Makes it Worse',
              hint: 'Any activities, foods, or situations that worsen your condition',
              maxLines: 2,
            ),
            
            // Allergies
            _buildTextFormField(
              controller: _allergiesController,
              label: 'Known Allergies',
              hint: 'List any allergies to medications, foods, or other substances',
              maxLines: 2,
            ),
            
            // Medical History
            _buildTextFormField(
              controller: _medicalHistoryController,
              label: 'Relevant Medical History',
              hint: 'Previous surgeries, chronic conditions, family history',
              maxLines: 3,
            ),
            
            // Emergency Contact
            _buildTextFormField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              hint: 'Name and phone number of emergency contact',
            ),
            
            // Additional Notes
            _buildTextFormField(
              controller: _additionalNotesController,
              label: 'Additional Notes',
              hint: 'Any other information you think might be helpful',
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // File Upload Section
            const Text(
              'Upload Lab Results or Medical Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload any relevant lab results, X-rays, or medical documents (PDF, JPG, PNG)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade100,
                foregroundColor: Colors.teal.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            
            if (_uploadedFileNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Uploaded Files:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...List.generate(_uploadedFileNames.length, (index) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.attach_file,
                      color: Colors.teal.shade700,
                    ),
                    title: Text(_uploadedFileNames[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Time',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred appointment date and time',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Appointment Type
          _buildDropdownField(
            label: 'Appointment Type',
            value: _selectedAppointmentType,
            items: _appointmentTypes,
            onChanged: (value) => setState(() => _selectedAppointmentType = value),
            required: true,
          ),
          
          // Urgency Level
          _buildDropdownField(
            label: 'Urgency Level',
            value: _selectedUrgency,
            items: _urgencyLevels,
            onChanged: (value) => setState(() => _selectedUrgency = value),
            required: true,
          ),
          
          // Consultation Channel
          _buildDropdownField(
            label: 'Consultation Channel',
            value: _selectedConsultationChannel,
            items: _consultationChannels,
            onChanged: (value) => setState(() => _selectedConsultationChannel = value),
            required: true,
          ),
          
          const SizedBox(height: 24),
          
          // Date Selection
          Card(
            child: ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: Colors.teal.shade700,
              ),
              title: const Text('Appointment Date'),
              subtitle: Text(
                _selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                    : 'Tap to select date',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time Selection
          Card(
            child: ListTile(
              leading: Icon(
                Icons.access_time,
                color: Colors.teal.shade700,
              ),
              title: const Text('Appointment Time'),
              subtitle: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Tap to select time',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTime,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment Section (Inactive)
          Card(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment integration coming soon. Currently, all consultations are free.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Free Consultation',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewAndSubmitPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review all information before submitting your appointment request',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Provider Information
          if (_selectedProvider != null)
            _buildReviewCard(
              title: 'Healthcare Provider',
              icon: Icons.person,
              children: [
                _buildReviewRow('Name', _selectedProvider!['name']),
                _buildReviewRow('Type', _selectedProvider!['type']),
                _buildReviewRow('Specialization', _selectedProvider!['specialization']),
                _buildReviewRow('Location', _selectedProvider!['location']),
              ],
            ),
          
          // Appointment Details
          _buildReviewCard(
            title: 'Appointment Details',
            icon: Icons.event,
            children: [
              _buildReviewRow('Type', _selectedAppointmentType ?? 'Not specified'),
              _buildReviewRow('Urgency', _selectedUrgency ?? 'Not specified'),
              _buildReviewRow('Channel', _selectedConsultationChannel ?? 'Not specified'),
              _buildReviewRow(
                'Date',
                _selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                    : 'Not selected',
              ),
              _buildReviewRow(
                'Time',
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Not selected',
              ),
            ],
          ),
          
          // Medical Information
          _buildReviewCard(
            title: 'Medical Information',
            icon: Icons.medical_information,
            children: [
              if (_selectedMainReason != null && (_selectedMainReason != 'Other' || _otherMainReason.isNotEmpty))
                _buildReviewRow('Main Complaint', _selectedMainReason == 'Other' ? _otherMainReason : _selectedMainReason ?? ''),
              if (_symptomsController.text.isNotEmpty)
                _buildReviewRow('Symptoms', _symptomsController.text),
              if (_durationController.text.isNotEmpty)
                _buildReviewRow('Duration', _durationController.text),
              if (_selectedSeverity != null)
                _buildReviewRow('Severity', _selectedSeverity!),
              if (_medicationsTakenController.text.isNotEmpty)
                _buildReviewRow('Current Medications', _medicationsTakenController.text),
              if (_allergiesController.text.isNotEmpty)
                _buildReviewRow('Allergies', _allergiesController.text),
            ],
          ),
          
          // Uploaded Files
          if (_uploadedFileNames.isNotEmpty)
            _buildReviewCard(
              title: 'Uploaded Documents',
              icon: Icons.attach_file,
              children: _uploadedFileNames
                  .map((name) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $name'),
                      ))
                  .toList(),
            ),
          
          const SizedBox(height: 24),
          
          // Important Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Important Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Your appointment request will be reviewed by the selected healthcare provider\n'
                  '• You will receive a notification once your appointment is approved or if any changes are needed\n'
                  '• All information provided will be saved to your health records\n'
                  '• This information will be available to your healthcare provider before the consultation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade700),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade700),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an option';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderIcon(String type) {
    IconData iconData;
    Color iconColor = Colors.teal.shade700;
    
    switch (type) {
      case 'Doctor':
        iconData = Icons.local_hospital;
        break;
      case 'Community Health Worker':
        iconData = Icons.health_and_safety;
        break;
      default:
        iconData = Icons.person;
    }
    
    return Icon(iconData, color: iconColor, size: 28);
  }

  Color _getProviderTypeColor(String type) {
    switch (type) {
      case 'Doctor':
        return Colors.blue.shade600;
      case 'Community Health Worker':
        return Colors.green.shade600;
      default:
        return Colors.teal.shade600;
    }
  }
}

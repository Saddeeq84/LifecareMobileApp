// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_brace_in_string_interps, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CHWStartConsultationScreen extends StatelessWidget {
  final String appointmentId;
  final String patientName;
  final String patientId;
  final String? doctorName;
  final String? doctorId;

  const CHWStartConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.patientId,
    this.doctorName,
    this.doctorId,
  });

  void _showConsultationMethodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Consultation Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.video_call, color: Colors.blue),
                title: Text('Video Call'),
                subtitle: Text('Start a live video consultation'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog(context, 'Video Call');
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('Audio Call'),
                subtitle: Text('Start an audio-only consultation'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog(context, 'Audio Call');
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble, color: Colors.orange),
                title: Text('Text Chat'),
                subtitle: Text('Start a text-based consultation'),
                onTap: () {
                  Navigator.pop(context);
                  // Open chat for this specific patient
                  GoRouter.of(context).pushNamed(
                    'chw-messages',
                    extra: {
                      'patientId': patientId,
                      'patientName': patientName,
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _addHealthNotes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.teal.shade600),
            const SizedBox(width: 8),
            const Text('Consultation Guide'),
          ],
        ),
        content: const Text(
          'Please review the consultation guidelines before adding health notes. Ensure all relevant patient information and observations are documented accurately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).pushNamed(
                'chw-anc-consultation-details',
                extra: {
                  'appointmentId': appointmentId,
                  'patientId': patientId,
                  'patientName': patientName,
                  'appointmentData': {'fromHealthNotes': true},
                },
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _referToDoctor(BuildContext context) {
    GoRouter.of(context).pushNamed('chw-create-referral');
  }
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Consultation'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Refer to Doctor'),
                      onPressed: () => _referToDoctor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _showConsultationMethodDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.note_add),
                  label: const Text('Add Health Notes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _addHealthNotes(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

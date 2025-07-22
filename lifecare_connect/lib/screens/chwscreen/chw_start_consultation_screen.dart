// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Consultation'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Patient: $patientName')),
                    ],
                  ),
                  if (doctorName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.medical_services, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Supervising Doctor: $doctorName')),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Appointment ID: ${appointmentId.substring(0, 8)}...'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Consultation Options
            Text(
              'Choose Consultation Method:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Video Call Option
            _buildConsultationOption(
              context,
              icon: Icons.video_call,
              title: 'Video Call',
              description: 'Start a live video consultation with patient',
              color: Colors.blue,
              onTap: () => _startVideoCall(context),
            ),
            const SizedBox(height: 12),
            
            // Audio Call Option
            _buildConsultationOption(
              context,
              icon: Icons.phone,
              title: 'Audio Call',
              description: 'Start an audio-only consultation with patient',
              color: Colors.green,
              onTap: () => _startAudioCall(context),
            ),
            const SizedBox(height: 12),
            
            // Chat Option
            _buildConsultationOption(
              context,
              icon: Icons.chat_bubble,
              title: 'Text Chat',
              description: 'Start a text-based consultation with patient',
              color: Colors.orange,
              onTap: () => _startChat(context),
            ),
            
            const SizedBox(height: 24),
            
            // CHW Specific Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.note_add),
                    label: const Text('Health Notes'),
                    onPressed: () => _addHealthNotes(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Refer to Doctor'),
                    onPressed: () => _referToDoctor(context),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Help Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'CHW Guidelines',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide community health support and refer complex cases to doctors when needed.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    _showComingSoonDialog(context, 'Video Call');
  }

  void _startAudioCall(BuildContext context) {
    _showComingSoonDialog(context, 'Audio Call');
  }

  void _startChat(BuildContext context) {
    _showComingSoonDialog(context, 'Text Chat');
  }

  void _addHealthNotes(BuildContext context) {
    _showComingSoonDialog(context, 'Health Notes');
  }

  void _referToDoctor(BuildContext context) {
    _showComingSoonDialog(context, 'Refer to Doctor');
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upcoming, color: Colors.teal.shade600),
            const SizedBox(width: 8),
            const Text('Coming Soon'),
          ],
        ),
        content: Text(
          '$feature functionality is under development and will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

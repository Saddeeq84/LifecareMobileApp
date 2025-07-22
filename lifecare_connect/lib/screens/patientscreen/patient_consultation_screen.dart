// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientConsultationScreen extends StatefulWidget {
  const PatientConsultationScreen({super.key});

  @override
  State<PatientConsultationScreen> createState() => _PatientConsultationScreenState();
}

class _PatientConsultationScreenState extends State<PatientConsultationScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<Map<String, dynamic>> dueAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDueAppointments();
  }

  Future<void> _loadDueAppointments() async {
    try {
      final now = DateTime.now();
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .where('appointmentDate', isLessThanOrEqualTo: Timestamp.fromDate(now.add(const Duration(hours: 1))))
          .get();

      setState(() {
        dueAppointments = appointmentsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading due appointments: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Consultation"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dueAppointments.isEmpty
              ? _buildNoAppointmentsView()
              : _buildAppointmentsList(),
    );
  }

  Widget _buildNoAppointmentsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'No Due Consultations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You don\'t have any approved appointments\ndue for consultation at this time.',
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
      itemCount: dueAppointments.length,
      itemBuilder: (context, index) {
        final appointment = dueAppointments[index];
        final appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();
        final isOverdue = appointmentDate.isBefore(DateTime.now());
        
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
                      isOverdue ? Icons.warning : Icons.schedule,
                      color: isOverdue ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOverdue ? 'Overdue Consultation' : 'Due Consultation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Appointment Details
                _buildDetailRow('Provider:', appointment['staffName'] ?? 'Unknown'),
                _buildDetailRow('Reason:', appointment['reason'] ?? 'General Consultation'),
                _buildDetailRow('Date:', _formatDateTime(appointmentDate)),
                
                const SizedBox(height: 16),
                
                // Consultation Options
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _startChatConsultation(appointment),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.video_call),
                        label: const Text('Video Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _startVideoConsultation(appointment),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // WhatsApp Option
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    label: const Text('WhatsApp Call'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                    ),
                    onPressed: () => _startWhatsAppConsultation(appointment),
                  ),
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
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 0) {
          return 'Overdue by ${(-difference.inMinutes)} minutes';
        } else {
          return 'In ${difference.inMinutes} minutes';
        }
      } else if (difference.inHours < 0) {
        return 'Overdue by ${(-difference.inHours)} hours';
      } else {
        return 'In ${difference.inHours} hours';
      }
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _startChatConsultation(Map<String, dynamic> appointment) {
    // Navigate to in-app chat with the provider
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Chat Consultation'),
        content: Text('Starting chat consultation with ${appointment['staffName']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to chat conversation screen
              Navigator.of(context).pushNamed(
                '/patient/conversation',
                arguments: {
                  'conversationId': appointment['id'],
                  'providerName': appointment['providerName'] ?? 'Healthcare Provider',
                  'providerId': appointment['providerId'],
                  'type': appointment['providerType'] == 'doctor' ? 'doctor_patient' : 'chw_patient',
                },
              );
              _updateConsultationStatus(appointment['id'], 'in_progress_chat');
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _startVideoConsultation(Map<String, dynamic> appointment) {
    // Start video call consultation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Video Consultation'),
        content: Text('Starting video consultation with ${appointment['staffName']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Integrate with video calling service
              _launchVideoCall(appointment);
              _updateConsultationStatus(appointment['id'], 'in_progress_video');
            },
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _startWhatsAppConsultation(Map<String, dynamic> appointment) async {
    try {
      // Get provider's phone number from Firestore
      final staffDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(appointment['staffId'])
          .get();
      
      if (staffDoc.exists) {
        final staffData = staffDoc.data() as Map<String, dynamic>;
        final phoneNumber = staffData['phone'] ?? '';
        
        if (phoneNumber.isNotEmpty) {
          final whatsappUrl = 'https://wa.me/$phoneNumber?text=Hello, I\'m ready for our consultation appointment.';
          
          if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
            await launchUrl(Uri.parse(whatsappUrl));
            _updateConsultationStatus(appointment['id'], 'in_progress_whatsapp');
          } else {
            throw 'Could not launch WhatsApp';
          }
        } else {
          throw 'Provider phone number not available';
        }
      } else {
        throw 'Provider information not found';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchVideoCall(Map<String, dynamic> appointment) async {
    try {
      // For now, we'll show a placeholder for video call integration
      // In a real app, you would integrate with a video calling service like Agora, Jitsi, or Zoom
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Video Call'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_call, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text('Video call with ${appointment['staffName']} would start here.'),
              const SizedBox(height: 8),
              const Text(
                'This would integrate with a video calling service like Agora, Jitsi, or Zoom SDK.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting video call: $e')),
      );
    }
  }

  Future<void> _updateConsultationStatus(String appointmentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': status,
        'consultationStarted': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating consultation status: $e');
    }
  }
}

// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, unused_import, unused_element, use_key_in_widget_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chw_start_consultation_screen.dart';
import '../../../shared/data/services/consultation_service.dart';
import '../../../shared/data/models/appointment.dart';

class CHWAppointmentsScreen extends StatelessWidget {
  final int initialTab;
  const CHWAppointmentsScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chwUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CHW Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'Upcoming Visits'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Requests Tab
            _buildAppointmentsList(context, chwUid, 'pending'),
            // Upcoming Visits Tab
            _buildAppointmentsList(context, chwUid, 'approved'),
            // Completed Tab
            _buildAppointmentsList(context, chwUid, 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context, String chwUid, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('providerId', isEqualTo: chwUid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final appointments = snapshot.data?.docs ?? [];
        if (appointments.isEmpty) {
          return Center(child: Text('No ${status == 'pending' ? 'pending requests' : status == 'approved' ? 'upcoming visits' : 'completed appointments'}'));
        }
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final doc = appointments[index];
            final data = doc.data() as Map<String, dynamic>;
            final appointmentDate = (data['appointmentDate'] as Timestamp).toDate();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _getStatusColor(status),
              child: ExpansionTile(
                title: Text(data['patientName'] ?? 'Unknown Patient'),
                subtitle: Text('Date: ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}'),
                children: [
                  if (data['preConsultationData'] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pre-Consultation Checklist:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._buildPreConsultationDetails(data['preConsultationData']),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status == 'pending') ...[
                        ElevatedButton(
                          onPressed: () => _showApproveDialog(context, doc.id),
                          child: const Text('Approve'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showRescheduleDialog(context, doc),
                          child: const Text('Reschedule'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showDenyDialog(context, doc.id),
                          child: const Text('Deny'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                      if (status == 'approved') ...[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showRescheduleDialog(context, doc),
                        ),
                      ],
                      if (status == 'completed')
                        Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPreConsultationDetails(Map<String, dynamic> checklist) {
    final List<Widget> items = [];
    checklist.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        items.add(Text('$key: $value', style: TextStyle(fontSize: 13)));
      }
    });
    return items;
  }

  void _showApproveDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Appointment'),
        content: const Text('Are you sure you want to approve this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _approveAppointment(context, appointmentId);
              Navigator.pop(context);
              // ...existing code...
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showDenyDialog(BuildContext context, String appointmentId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for denial:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _denyAppointment(context, appointmentId, reasonController.text.trim());
              Navigator.pop(context);
                    // Message to patient about denial is already handled in _denyAppointment
            },
            child: const Text('Deny'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime selectedDate = (data['appointmentDate'] as Timestamp).toDate();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reschedule Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('Time: ${selectedTime.format(context)}'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _rescheduleAppointment(context, doc.id, selectedDate, selectedTime),
                  child: const Text('Reschedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rescheduleAppointment(BuildContext context, String appointmentId, DateTime date, TimeOfDay time) async {
    final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    
    try {
      // Example Firestore update using newDateTime
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'appointmentDate': Timestamp.fromDate(newDateTime)});

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rescheduling: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveAppointment(BuildContext context, String appointmentId) async {
    try {
      // Update appointment status to approved
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'approved'});

      // Fetch appointment details
      final appointmentDoc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      if (!appointmentDoc.exists) throw Exception('Appointment not found');
      final appointment = Appointment.fromFirestore(appointmentDoc);

      // Create consultation if not already exists for this appointment
      final existingConsultations = await FirebaseFirestore.instance
          .collection('consultations')
          .where('appointmentId', isEqualTo: appointmentId)
          .get();
      if (existingConsultations.docs.isEmpty) {
        await ConsultationService.createConsultation(
          patientId: appointment.patientId,
          patientName: appointment.patientName,
          doctorId: appointment.providerId,
          doctorName: appointment.providerName,
          facilityId: appointment.facilityId,
          facilityName: appointment.facilityName,
          type: appointment.appointmentType,
          reason: appointment.reason,
          chiefComplaint: appointment.notes,
          scheduledDateTime: appointment.appointmentDate,
          estimatedDurationMinutes: 30,
          priority: 'routine',
          referralId: null,
          appointmentId: appointment.id,
          notes: appointment.notes,
          createdBy: appointment.providerId,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment approved'), backgroundColor: Colors.green),
        );
      }
      // Send message to patient about approval
      await _sendPatientMessage(appointmentId, 'Your appointment has been approved by the CHW.');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markComplete(BuildContext context, String appointmentId) async {
    try {
      // Example Firestore update to mark appointment as completed
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'completed'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _denyAppointment(BuildContext context, String appointmentId, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'status': 'denied',
            'denialReason': reason,
          });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment denied'), backgroundColor: Colors.red),
        );
      }
      // Send message to patient with denial reason
      await _sendPatientMessage(appointmentId, 'Your appointment was denied by the CHW. Reason: $reason');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendPatientMessage(String appointmentId, String message) async {
    // Fetch patientId from appointment
    final doc = await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).get();
    final data = doc.data();
    if (data == null) return;
    final patientId = data['patientId'];
    if (patientId == null) return;
    await FirebaseFirestore.instance.collection('messages').add({
      'to': patientId,
      'from': FirebaseAuth.instance.currentUser?.uid ?? '',
      'appointmentId': appointmentId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'system',
    });
  }

  void _startConsultation(BuildContext context, String appointmentId, Map<String, dynamic> appointmentData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CHWStartConsultationScreen(
          appointmentId: appointmentId,
          patientName: appointmentData['patientName'] ?? 'Unknown Patient',
          patientId: appointmentData['patientId'] ?? '',
          doctorName: appointmentData['doctor'],
          doctorId: appointmentData['doctorId'],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'approved':
        return Colors.green.shade100;
      case 'denied':
        return Colors.red.shade100;
      case 'completed':
        return Colors.blue.shade100;
      case 'cancelled':
        return Colors.grey.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'approved':
        return Colors.green.shade800;
      case 'denied':
        return Colors.red.shade800;
      case 'completed':
        return Colors.blue.shade800;
      case 'cancelled':
        return Colors.grey.shade800;
      default:
        return Colors.orange.shade800;
    }
  }
}

// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../shared/data/services/appointment_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'patient_staff_selection_screen.dart';
// import 'patient_referrals_screen.dart';
// import 'patient_consultations_screen.dart';
import 'package:go_router/go_router.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Now 2 tabs: Pending Appointment, Pending Consultation
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print("📅 PatientAppointmentsScreen loaded for UID: $_userId");
  }

  void _navigateToBookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientStaffSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.green.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Appointment'),
            Tab(text: 'Pending Consultation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentsList(statusFilter: 'pending', userId: _userId),
          _AppointmentsList(statusFilter: 'approved', userId: _userId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToBookAppointment,
        icon: const Icon(Icons.add),
        label: const Text("Book Appointment"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// ------------------------ 🩺 Appointments List ------------------------

class _AppointmentsList extends StatelessWidget {
  final String statusFilter;
  final String userId;

  const _AppointmentsList({
    required this.statusFilter,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Use appointment service for patient appointments
    Stream<QuerySnapshot> appointmentStream;
    
    if (statusFilter == 'pending') {
      appointmentStream = AppointmentService.getPatientAppointments(
        patientId: userId,
        status: 'pending',
      );
    } else if (statusFilter == 'approved') {
      appointmentStream = AppointmentService.getPatientAppointments(
        patientId: userId,
        status: 'approved',
      );
    } else if (statusFilter == 'completed') {
      appointmentStream = AppointmentService.getPatientAppointments(
        patientId: userId,
        status: 'completed',
      );
    } else {
      appointmentStream = AppointmentService.getPatientAppointments(
        patientId: userId,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Unable to load appointments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data?.docs ?? [];
        final isFromCache = appointments.isNotEmpty && appointments.first.metadata.isFromCache;

        if (appointments.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        return Column(
          children: [
            // Offline indicator
            if (isFromCache)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Showing offline data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final doc = appointments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  return _buildAppointmentCard(context, doc.id, data);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    String title;
    String subtitle;
    IconData icon;
    
    switch (status) {
      case 'pending':
        title = 'No Pending Appointments';
        subtitle = 'Your appointment requests will appear here';
        icon = Icons.pending_actions;
        break;
      case 'approved':
        title = 'No Upcoming Appointments';
        subtitle = 'Your confirmed appointments will appear here';
        icon = Icons.event_available;
        break;
      case 'completed':
        title = 'No Completed Appointments';
        subtitle = 'Your appointment history will appear here';
        icon = Icons.history;
        break;
      default:
        title = 'No Appointments';
        subtitle = 'Your appointments will appear here';
        icon = Icons.event_busy;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



}

// ------------------------ 🩺 Patient Consultations Screen ------------------------
class PatientConsultationsScreen extends StatelessWidget {
  const PatientConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .where('status', isEqualTo: 'completed')
            .orderBy('completedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading consultations'));
          }
          final consultations = snapshot.data?.docs ?? [];
          if (consultations.isEmpty) {
            return const Center(child: Text('No completed consultations yet.'));
          }
          return ListView.builder(
            itemCount: consultations.length,
            itemBuilder: (context, index) {
              final data = consultations[index].data() as Map<String, dynamic>;
              final date = data['completedAt'] != null
                  ? (data['completedAt'] as Timestamp).toDate()
                  : null;
              final dateStr = date != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(date)
                  : 'Date not set';
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(data['appointmentType'] ?? 'Consultation'),
                  subtitle: Text('Provider: ${data['providerName'] ?? 'N/A'}\nDate: $dateStr'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AppointmentDetailsDialog(data: data),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
  
  extension on _AppointmentsList {
  Widget _buildAppointmentCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final appointmentDate = data['appointmentDate'] != null
        ? (data['appointmentDate'] as Timestamp).toDate()
        : null;

    final dateStr = appointmentDate != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(appointmentDate)
        : 'Date not set';

    final providerName = data['providerName'] ?? data['doctor'] ?? 'Unknown Provider';
    final providerType = data['providerType'] ?? 'Healthcare Provider';
    final appointmentType = data['appointmentType'] ?? 'General Consultation';
    final urgency = data['urgency'] ?? 'Normal';
    final status = data['status'] ?? 'pending';

    Color cardColor = Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointmentType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Provider: $providerName ($providerType)',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $dateStr',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Urgency: $urgency',
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
            const SizedBox(height: 8),
            if (data['preConsultationData'] != null &&
                data['preConsultationData']['mainComplaint'] != null)
              Text(
                'Complaint: ${data['preConsultationData']['mainComplaint']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'approved') ...[
                  TextButton.icon(
                    onPressed: () => _viewAppointmentDetails(context, data),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.blue),
                    tooltip: 'Video Call',
                    onPressed: () => _showComingSoonDialog(context, 'Video Call'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    tooltip: 'Audio Call',
                    onPressed: () => _showComingSoonDialog(context, 'Audio Call'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.orange),
                    tooltip: 'Chat',
                    onPressed: () => _openChat(context, data),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.teal),
                    tooltip: 'Mark Complete',
                    onPressed: () => _markComplete(context, docId, data),
                  ),
                ]
                else if (status == 'pending') ...[
                  TextButton.icon(
                    onPressed: () => _viewAppointmentDetails(context, data),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _cancelAppointment(context, docId),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ]
                else if (status == 'completed') ...[
                  TextButton.icon(
                    onPressed: () => _viewCompletedAppointment(context, data),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('View Summary'),
                  ),
                ]
                else ...[
                  TextButton.icon(
                    onPressed: () => _viewAppointmentDetails(context, data),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, Map<String, dynamic> appointmentData) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final providerId = appointmentData['providerId'] ?? '';
    final providerName = appointmentData['providerName'] ?? 'Health Worker';

    // Find or create a conversation between patient and provider
    FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: currentUserId)
        .where('recipientType', isEqualTo: appointmentData['providerRole'] ?? 'chw')
        .get()
        .then((snapshot) async {
      String? conversationId;
      for (var doc in snapshot.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(providerId)) {
          conversationId = doc.id;
          break;
        }
      }
      if (conversationId == null) {
        final docRef = await FirebaseFirestore.instance.collection('messages').add({
          'participants': [currentUserId, providerId],
          'recipientType': appointmentData['providerRole'] ?? 'chw',
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': 'Conversation started',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount_$currentUserId': 0,
          'unreadCount_$providerId': 0,
        });
        conversationId = docRef.id;
      }
      GoRouter.of(context).push(
        '/patientMessaging',
        extra: {
          'openConversationId': conversationId,
          'recipientId': providerId,
          'recipientName': providerName,
          'recipientType': appointmentData['providerRole'] ?? 'chw',
        },
      );
    });
  }

  Future<void> _markComplete(BuildContext context, String docId, Map<String, dynamic> appointmentData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Appointment Complete'),
        content: const Text('Are you sure you want to mark this appointment as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Yes, Mark Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(docId)
            .update({'status': 'completed', 'completedAt': FieldValue.serverTimestamp()});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment marked as complete'), backgroundColor: Colors.green),
        );
        // Optionally navigate to consultations screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PatientConsultationsScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
    }
  Future<void> _cancelAppointment(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(docId)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancelledBy': 'patient',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error cancelling appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _viewAppointmentDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailsDialog(data: data),
    );
  }

  void _viewCompletedAppointment(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => CompletedAppointmentDialog(data: data),
    );
  }

// ------------------------ 📅 Appointments Calendar Tab ------------------------

class _AppointmentsCalendar extends StatefulWidget {
  final String userId;

  const _AppointmentsCalendar({required this.userId});

  @override
  State<_AppointmentsCalendar> createState() => _AppointmentsCalendarState();
}

class _AppointmentsCalendarState extends State<_AppointmentsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _selectedAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() async {
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: widget.userId)
        .get();

    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in query.docs) {
      final data = doc.data();
      final dateStr = data['date'];
      final parsedDate = DateTime.tryParse(dateStr ?? '');

      if (parsedDate != null) {
        final key = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        events.putIfAbsent(key, () => []).add(data);
      }
    }

    setState(() {
      _events = events;
      _selectedDay = _focusedDay;
      _selectedAppointments = events[_selectedDay] ?? [];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedAppointments = _events[selectedDay] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Map<String, dynamic>>(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          ),
        ),
        Expanded(
          child: _selectedAppointments.isEmpty
              ? const Center(child: Text('No appointments for this day.'))
              : ListView.builder(
                  itemCount: _selectedAppointments.length,
                  itemBuilder: (context, index) {
                    final data = _selectedAppointments[index];
                    final date = DateTime.tryParse(data['date'] ?? '')?.toLocal();
                    final dateStr = date != null
                        ? DateFormat.yMMMd().add_jm().format(date)
                        : 'Invalid date';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(data['reason'] ?? 'No reason'),
                        subtitle: Text('Time: $dateStr\nDoctor: ${data['doctor'] ?? 'N/A'}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Appointment Details Dialog
class AppointmentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const AppointmentDetailsDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final preConsultationData = data['preConsultationData'] as Map<String, dynamic>?;
    final appointmentDate = data['appointmentDate'] != null
        ? (data['appointmentDate'] as Timestamp).toDate()
        : null;

    return AlertDialog(
      title: Text(data['appointmentType'] ?? 'Appointment Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Provider', '${data['providerName']} (${data['providerType']})'),
            _buildDetailRow('Date', appointmentDate != null 
                ? DateFormat('MMM dd, yyyy • hh:mm a').format(appointmentDate) 
                : 'Not set'),
            _buildDetailRow('Status', data['status'] ?? 'Unknown'),
            _buildDetailRow('Urgency', data['urgency'] ?? 'Normal'),
            
            if (preConsultationData != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Pre-Consultation Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              if (preConsultationData['mainComplaint'] != null)
                _buildDetailRow('Main Complaint', preConsultationData['mainComplaint']),
              if (preConsultationData['symptoms'] != null)
                _buildDetailRow('Symptoms', preConsultationData['symptoms']),
              if (preConsultationData['duration'] != null)
                _buildDetailRow('Duration', preConsultationData['duration']),
              if (preConsultationData['severity'] != null)
                _buildDetailRow('Severity', preConsultationData['severity']),
              if (preConsultationData['medicationsTaken'] != null)
                _buildDetailRow('Medications', preConsultationData['medicationsTaken']),
              if (preConsultationData['allergies'] != null)
                _buildDetailRow('Allergies', preConsultationData['allergies']),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
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
}

// Completed Appointment Dialog
class CompletedAppointmentDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const CompletedAppointmentDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final completedAt = data['completedAt'] != null
        ? (data['completedAt'] as Timestamp).toDate()
        : null;

    return AlertDialog(
      title: const Text('Appointment Summary'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Provider', '${data['providerName']} (${data['providerType']})'),
            _buildDetailRow('Type', data['appointmentType'] ?? 'General Consultation'),
            _buildDetailRow('Completed', completedAt != null 
                ? DateFormat('MMM dd, yyyy • hh:mm a').format(completedAt) 
                : 'Date not available'),
            
            const SizedBox(height: 16),
            const Text(
              'Consultation completed successfully.',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your health records for detailed consultation notes and prescriptions.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to health records
            // You can implement this navigation based on your app structure
          },
          child: const Text('View Health Records'),
        ),
      ],
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
}

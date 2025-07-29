// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/data/models/consultation.dart';
import '../../../shared/data/services/consultation_service.dart';
// import 'package:go_router/go_router.dart';
import 'chat_chw_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientConsultationTabbedScreen extends StatefulWidget {
  const PatientConsultationTabbedScreen({super.key});

  @override
  State<PatientConsultationTabbedScreen> createState() => _PatientConsultationTabbedScreenState();
}

class _PatientConsultationTabbedScreenState extends State<PatientConsultationTabbedScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingConsultationsTab(),
          _CompletedConsultationsTab(),
        ],
      ),
    );
  }
}

// Pending Consultations Tab
class _PendingConsultationsTab extends StatefulWidget {
  @override
  State<_PendingConsultationsTab> createState() => _PendingConsultationsTabState();
}

class _PendingConsultationsTabState extends State<_PendingConsultationsTab> {
  List<Consultation> _pendingConsultations = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadConsultations();
  }

  void _loadConsultations() {
    if (_currentUserId == null) return;
    setState(() { _isLoading = true; });
    ConsultationService.getPatientConsultations(patientId: _currentUserId!)
        .listen((snapshot) {
      final consultations = snapshot.docs
          .map((doc) => Consultation.fromFirestore(doc))
          .where((c) => c.status == 'pending' || c.status == 'approved')
          .toList();
      setState(() {
        _pendingConsultations = consultations;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consultations: $error')),
        );
      }
    });
  }

  void _startChat(Consultation consultation) {
    // Navigate to chat screen with CHW/doctor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatCHWScreen(
          chwUid: consultation.doctorId,
          chwName: consultation.doctorName,
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingConsultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending consultations', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loadConsultations(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingConsultations.length,
        itemBuilder: (context, index) {
          final consultation = _pendingConsultations[index];
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
                      Icon(Icons.medical_services, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(child: Text(consultation.doctorName)),
                      Text(consultation.formattedScheduledDateTime),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          onPressed: () => _startChat(consultation),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.video_call),
                          label: const Text('Video Call'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                          onPressed: () => _showComingSoon('Video Call'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text('Audio Call'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                          onPressed: () => _showComingSoon('Audio Call'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Completed Consultations Tab
class _CompletedConsultationsTab extends StatefulWidget {
  @override
  State<_CompletedConsultationsTab> createState() => _CompletedConsultationsTabState();
}

class _CompletedConsultationsTabState extends State<_CompletedConsultationsTab> {
  List<Consultation> _completedConsultations = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadConsultations();
  }

  void _loadConsultations() {
    if (_currentUserId == null) return;
    setState(() { _isLoading = true; });
    ConsultationService.getPatientConsultations(patientId: _currentUserId!)
        .listen((snapshot) {
      final consultations = snapshot.docs
          .map((doc) => Consultation.fromFirestore(doc))
          .where((c) => c.status == 'completed')
          .toList();
      setState(() {
        _completedConsultations = consultations;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consultations: $error')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_completedConsultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No completed consultations', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loadConsultations(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedConsultations.length,
        itemBuilder: (context, index) {
          final consultation = _completedConsultations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text(consultation.doctorName),
              subtitle: Text(consultation.formattedScheduledDateTime),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Show summary dialog or details
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Consultation Summary'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Doctor: ${consultation.doctorName}'),
                          if (consultation.facilityName?.isNotEmpty == true)
                            Text('Facility: ${consultation.facilityName!}'),
                          Text('Type: ${consultation.typeDisplayText}'),
                          Text('Date: ${consultation.formattedScheduledDateTime}'),
                          if (consultation.diagnosis?.isNotEmpty == true)
                            Text('Diagnosis: ${consultation.diagnosis!}'),
                          if (consultation.prescriptions?.isNotEmpty == true) ...[
                            SizedBox(height: 8),
                            Text('Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...consultation.prescriptions!.map((p) => Text('- $p')),
                          ],
                          if (consultation.notes?.isNotEmpty == true)
                            Text('Notes: ${consultation.notes!}'),
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
              },
            ),
          );
        },
      ),
    );
  }
}
class _ConsultationHistoryTab extends StatefulWidget {
  @override
  State<_ConsultationHistoryTab> createState() => _ConsultationHistoryTabState();
}

class _ConsultationHistoryTabState extends State<_ConsultationHistoryTab> {
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadConsultations();
  }

  void _loadConsultations() {
    if (_currentUserId == null) return;
    setState(() { _isLoading = true; });
    ConsultationService.getPatientConsultations(patientId: _currentUserId!)
        .listen((snapshot) {
      final consultations = snapshot.docs
          .map((doc) => Consultation.fromFirestore(doc))
          .toList();
      setState(() {
        _consultations = consultations;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consultations: $error')),
        );
      }
    });
  }

  Future<void> _refreshConsultations() async {
    _loadConsultations();
  }

  void _showConsultationDetails(Consultation consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consultation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Doctor', consultation.doctorName),
              if (consultation.facilityName?.isNotEmpty == true)
                _buildDetailRow('Facility', consultation.facilityName!),
              _buildDetailRow('Type', consultation.typeDisplayText),
              _buildDetailRow('Status', consultation.statusDisplayText),
              _buildDetailRow('Priority', consultation.priorityDisplayText),
              _buildDetailRow('Scheduled', consultation.formattedScheduledDateTime),
              _buildDetailRow('Duration', '${consultation.estimatedDurationMinutes} minutes'),
              if (consultation.reason?.isNotEmpty == true)
                _buildDetailRow('Reason', consultation.reason!),
              if (consultation.chiefComplaint?.isNotEmpty == true)
                _buildDetailRow('Chief Complaint', consultation.chiefComplaint!),
              if (consultation.notes?.isNotEmpty == true)
                _buildDetailRow('Notes', consultation.notes!),
              if (consultation.diagnosis?.isNotEmpty == true)
                _buildDetailRow('Diagnosis', consultation.diagnosis!),
              if (consultation.prescriptions?.isNotEmpty == true) ...[
                SizedBox(height: 8),
                Text('Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                ...consultation.prescriptions!.map((prescription) =>
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('\u2022 $prescription'),
                  )),
              ],
              if (consultation.recommendations?.isNotEmpty == true) ...[
                SizedBox(height: 8),
                Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                ...consultation.recommendations!.map((recommendation) =>
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('\u2022 $recommendation'),
                  )),
              ],
              if (consultation.followUpInstructions?.isNotEmpty == true)
                _buildDetailRow('Follow-up Instructions', consultation.followUpInstructions!),
              if (consultation.nextAppointmentDate != null)
                _buildDetailRow('Next Appointment',
                  '${consultation.nextAppointmentDate!.day}/${consultation.nextAppointmentDate!.month}/${consultation.nextAppointmentDate!.year}'),
              if (consultation.cancellationReason?.isNotEmpty == true)
                _buildDetailRow('Cancellation Reason', consultation.cancellationReason!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _consultations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No consultations yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Your healthcare provider will schedule consultations when needed', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshConsultations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) {
                    final consultation = _consultations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(Icons.medical_services, color: Colors.teal),
                        title: Text(consultation.doctorName),
                        subtitle: Text(consultation.formattedScheduledDateTime),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _showConsultationDetails(consultation),
                      ),
                    );
                  },
                ),
              );
  }
}

class _StartConsultationTab extends StatefulWidget {
  @override
  State<_StartConsultationTab> createState() => _StartConsultationTabState();
}

class _StartConsultationTabState extends State<_StartConsultationTab> {
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

  Widget _buildNoAppointmentsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          Text('No Due Consultations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 16),
          Text('You don\'t have any approved appointments\ndue for consultation at this time.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
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
                    Icon(isOverdue ? Icons.warning : Icons.schedule, color: isOverdue ? Colors.red : Colors.green),
                    const SizedBox(width: 8),
                    Text(isOverdue ? 'Overdue Consultation' : 'Due Consultation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Provider:', appointment['staffName'] ?? 'Unknown'),
                _buildDetailRow('Reason:', appointment['reason'] ?? 'General Consultation'),
                _buildDetailRow('Date:', _formatDateTime(appointmentDate)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        onPressed: () => _startChatConsultation(appointment),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.video_call),
                        label: const Text('Video Call'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => _startVideoConsultation(appointment),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    label: const Text('WhatsApp Call'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
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
          return 'Overdue by  a0${(-difference.inMinutes)} minutes';
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
    // Implement chat consultation logic here
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat consultation started!')));
  }

  void _startVideoConsultation(Map<String, dynamic> appointment) {
    // Implement video consultation logic here
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video call started!')));
  }

  void _startWhatsAppConsultation(Map<String, dynamic> appointment) async {
    final phone = appointment['providerPhone'] ?? '';
    if (phone.isNotEmpty) {
      final url = 'https://wa.me/$phone';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No provider phone number available')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : dueAppointments.isEmpty
            ? _buildNoAppointmentsView()
            : _buildAppointmentsList();
  }
}

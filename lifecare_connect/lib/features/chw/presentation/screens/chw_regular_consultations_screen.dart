// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, prefer_const_literals_to_create_immutables, await_only_futures

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../shared/data/models/appointment.dart';
import '../../../shared/data/services/appointment_service.dart';
import '../../../shared/data/services/consultation_service.dart';
import 'chw_consultation_details_screen.dart';
import 'chw_anc_pnc_consultation_screen.dart';
import '../../../shared/data/services/message_service.dart';
import '../../../shared/presentation/screens/chat_screen.dart';

class CHWRegularConsultationsScreen extends StatefulWidget {
  const CHWRegularConsultationsScreen({super.key});

  @override
  State<CHWRegularConsultationsScreen> createState() => _CHWRegularConsultationsScreenState();
}

class _CHWRegularConsultationsScreenState extends State<CHWRegularConsultationsScreen> with TickerProviderStateMixin {
  StreamSubscription? _pendingSub;
  StreamSubscription? _completedSub;
  late TabController _tabController;
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _completedAppointments = [];
  bool _isLoading = true;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _pendingLoaded = false;
  bool _completedLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _pendingSub?.cancel();
    _completedSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
      _pendingLoaded = false;
      _completedLoaded = false;
    });

    // Cancel previous subscriptions if any
    _pendingSub?.cancel();
    _completedSub?.cancel();


    // Pending Consultations: approved appointments, not referred (include ANC/PNC and regular)
    _pendingSub = AppointmentService.getCHWAppointments(
      chwId: _currentUserId,
      statusList: ['approved']
    ).listen((snapshot) {
      final allAppointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      setState(() {
        _pendingAppointments = allAppointments.where((appointment) =>
          appointment.isApproved &&
          appointment.status != 'referred'
        ).toList();
        _pendingLoaded = true;
      });
      _checkLoadingComplete();
    });

    // Completed Consultations: query health_records for statusFlag: 'completed'
    _completedSub = FirebaseFirestore.instance
        .collection('health_records')
        .where('chwId', isEqualTo: _currentUserId)
        .where('statusFlag', isEqualTo: 'completed')
        .snapshots()
        .listen((snapshot) {
      final allRecords = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _completedAppointments = allRecords.map((data) {
          final record = data['data'] ?? {};
          return Appointment(
            id: record['appointmentId'] ?? data['appointmentId'] ?? '',
            patientId: record['patientId'] ?? data['patientId'] ?? '',
            patientName: record['patientName'] ?? data['patientName'] ?? '',
            providerId: data['chwId'] ?? record['chwId'] ?? '',
            providerName: data['providerName'] ?? 'Community Health Worker',
            providerType: data['providerType'] ?? 'CHW',
            appointmentDate: record['createdAt'] != null && record['createdAt'] is Timestamp ? (record['createdAt'] as Timestamp).toDate() : (data['createdAt'] != null && data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now()),
            reason: record['reason'] ?? record['notes'] ?? data['reason'] ?? data['notes'] ?? '',
            notes: record['notes'] ?? data['notes'] ?? '',
            status: 'completed',
            facilityId: null,
            facilityName: null,
            appointmentType: record['consultationType'] ?? record['type'] ?? data['consultationType'] ?? data['type'] ?? 'Consultation',
            createdAt: record['createdAt'] != null && record['createdAt'] is Timestamp ? (record['createdAt'] as Timestamp).toDate() : (data['createdAt'] != null && data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now()),
            updatedAt: record['updatedAt'] != null && record['updatedAt'] is Timestamp ? (record['updatedAt'] as Timestamp).toDate() : (data['updatedAt'] != null && data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now()),
            completedAt: data['completedAt'] != null && data['completedAt'] is Timestamp ? (data['completedAt'] as Timestamp).toDate() : null,
            statusNotes: null,
            rescheduleNotes: null,
            cancellationReason: null,
          );
        }).toList();
        _completedLoaded = true;
      });
      _checkLoadingComplete();
    });
  }

  void _checkLoadingComplete() {
    if (_pendingLoaded && _completedLoaded && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // Remove all actions to ensure no profile icon
        actions: null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending Consultations'),
            Tab(text: 'Completed Consultations'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingConsultationsTab(),
                _buildCompletedConsultationsTab(),
              ],
            ),
    );
  }


  Widget _buildPendingConsultationsTab() {
    if (_pendingAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Pending Consultations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'All your approved appointments (including ANC/PNC) will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = _pendingAppointments[index];
        return _buildUpcomingVisitCard(appointment);
      },
    );
  }

  Widget _buildCompletedConsultationsTab() {
    if (_completedAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Completed Consultations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed consultations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _completedAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = _completedAppointments.reversed.toList()[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getTypeColor(appointment.appointmentType),
                      child: Icon(
                        _getTypeIcon(appointment.appointmentType),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.appointmentType,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      appointment.formattedDateTime,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (appointment.reason.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.reason,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewCompletedConsultation(appointment),
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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

  void _viewCompletedConsultation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consultation Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${appointment.patientName}'),
              Text('Type: ${appointment.appointmentType}'),
              Text('Date: ${appointment.formattedDateTime}'),
              if (appointment.reason.isNotEmpty) Text('Reason: ${appointment.reason}'),
              if (appointment.notes != null && appointment.notes!.isNotEmpty) Text('Notes: ${appointment.notes}'),
              // Add more fields as needed for summary
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

  Widget _buildUpcomingVisitCard(Appointment appointment) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getTypeColor(appointment.appointmentType),
                  child: Icon(
                    _getTypeIcon(appointment.appointmentType),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.appointmentType,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'APPROVED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  appointment.formattedDateTime,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appointment.reason.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startConsultation(appointment),
                    icon: const Icon(Icons.play_circle_fill, size: 20),
                    label: const Text('Start Consultation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    if (_currentUserId == null) return;
                    // Get CHW info (current user)
                    final chwDoc = await FirebaseAuth.instance.currentUser;
                    final chwName = chwDoc?.displayName ?? 'CHW';
                    // Get patient info from appointment
                    final patientId = appointment.patientId;
                    final patientName = appointment.patientName;
                    // Create or get conversation
                    final conversationId = await MessageService.createOrGetConversation(
                      user1Id: _currentUserId,
                      user1Name: chwName,
                      user1Role: 'chw',
                      user2Id: patientId,
                      user2Name: patientName,
                      user2Role: 'patient',
                    );
                    // Navigate to chat screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          conversationId: conversationId,
                          otherParticipantName: patientName,
                          otherParticipantRole: 'patient',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Colors.teal, size: 24),
                  tooltip: 'Chat with Patient',
                ),
                IconButton(
                  onPressed: () => _showComingSoon('Video call'),
                  icon: const Icon(Icons.videocam, color: Colors.blue, size: 24),
                  tooltip: 'Video Call (Coming Soon)',
                ),
                IconButton(
                  onPressed: () => _showComingSoon('Audio call'),
                  icon: const Icon(Icons.call, color: Colors.green, size: 24),
                  tooltip: 'Audio Call (Coming Soon)',
                ),
                IconButton(
                  onPressed: () => _referToDoctor(appointment),
                  icon: const Icon(Icons.local_hospital, color: Colors.deepOrange, size: 24),
                  tooltip: 'Refer to Doctor',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'general consultation':
        return Colors.blue;
      case 'follow-up visit':
        return Colors.green;
      case 'emergency consultation':
        return Colors.red;
      case 'specialist referral':
        return Colors.purple;
      case 'health screening':
        return Colors.orange;
      case 'vaccination':
        return Colors.indigo;
      case 'mental health consultation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'general consultation':
        return Icons.medical_services;
      case 'follow-up visit':
        return Icons.schedule;
      case 'emergency consultation':
        return Icons.emergency;
      case 'specialist referral':
        return Icons.person_search;
      case 'health screening':
        return Icons.health_and_safety;
      case 'vaccination':
        return Icons.vaccines;
      case 'mental health consultation':
        return Icons.psychology;
      default:
        return Icons.local_hospital;
    }
  }


  void _startConsultation(Appointment appointment) async {
    try {
      // Create consultation from approved appointment
      final consultation = await ConsultationService.createConsultationFromAppointment(
        appointment,
        _currentUserId!,
      );

      if (consultation != null) {
        final type = appointment.appointmentType.toLowerCase();
        if (type.contains('anc') || type.contains('antenatal') || type.contains('pnc') || type.contains('postnatal')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CHWAncPncConsultationScreen(
                appointmentId: appointment.id,
                patientId: appointment.patientId,
                patientName: appointment.patientName,
                appointmentType: appointment.appointmentType,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CHWConsultationDetailsScreen(
                appointmentId: appointment.id,
                patientId: appointment.patientId,
                patientName: appointment.patientName,
                appointmentData: appointment.toFirestore(),
              ),
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consultation started successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting consultation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _referToDoctor(Appointment appointment) {
    context.push('/chw_dashboard/referrals/create', extra: {
      'patientId': appointment.patientId,
      'patientName': appointment.patientName,
      'appointmentId': appointment.id,
      'fromConsultation': true,
    }).then((_) {
      // Refresh data after returning from referral screen
      _loadData();
    });
  }
}
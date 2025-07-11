// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
    _tabController = TabController(length: 4, vsync: this); // Added 4th tab
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print("📅 PatientAppointmentsScreen loaded for UID: $_userId");
  }

  void _navigateToBookAppointment() {
    Navigator.pushNamed(context, '/book_patient_appointment');
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
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
            Tab(text: 'Calendar'), // New calendar tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentsList(statusFilter: 'pending', userId: _userId),
          _AppointmentsList(statusFilter: 'booked', userId: _userId),
          _AppointmentsList(statusFilter: 'completed', userId: _userId),
          _AppointmentsCalendar(userId: _userId), // New calendar view
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
    final query = FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: userId)
        .where('status', isEqualTo: statusFilter)
        .orderBy('date', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final appointments = snapshot.data?.docs ?? [];

        if (appointments.isEmpty) {
          return Center(child: Text('No $statusFilter appointments.'));
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final doc = appointments[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = DateTime.tryParse(data['date'] ?? '');
            final dateStr = date != null
                ? DateFormat.yMMMd().add_jm().format(date.toLocal())
                : 'Invalid date';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(data['reason'] ?? 'No reason provided'),
                subtitle: Text(
                  'Date: $dateStr\nDoctor: ${data['doctor'] ?? 'N/A'}\nStatus: ${data['status']}',
                ),
                isThreeLine: true,
                trailing: statusFilter != 'completed'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Cancel Appointment',
                        onPressed: () => _cancelAppointment(context, doc.id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelAppointment(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).update({'status': 'cancelled'});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
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
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: (day) => _events[day] ?? [],
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: 12),
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

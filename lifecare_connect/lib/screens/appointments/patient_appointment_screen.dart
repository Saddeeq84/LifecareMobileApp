// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    print("📅 PatientAppointmentsScreen loaded");
  }

  void _navigateToBookAppointment() {
    Navigator.pushNamed(context, '/book_patient_appointment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        backgroundColor: Colors.green.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentListPlaceholder(title: 'Pending Approval'),
          _AppointmentListPlaceholder(title: 'Upcoming Appointments'),
          _AppointmentListPlaceholder(title: 'Appointment History'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToBookAppointment,
        icon: Icon(Icons.add),
        label: Text("Book Appointment"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

class _AppointmentListPlaceholder extends StatelessWidget {
  final String title;

  const _AppointmentListPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    print("🧾 Displaying: $title");
    return Center(
      child: Text(title, style: TextStyle(fontSize: 18)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_appointment_tab.dart';
import 'pending_appointment_tab.dart';
import 'appointment_history_tab.dart';

class CentralAppointmentWidget extends StatefulWidget {
  final String role; // "patient", "chw", "doctor", "admin"
  const CentralAppointmentWidget({super.key, required this.role});

  @override
  State<CentralAppointmentWidget> createState() => _CentralAppointmentWidgetState();
}

class _CentralAppointmentWidgetState extends State<CentralAppointmentWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == 'admin';
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        bottom: const TabBar(
          tabs: [
            Tab(text: "Book"),
            Tab(text: "Pending"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (!isAdmin)
            BookAppointmentTab(role: widget.role)
          else
            const Center(child: Text("Admins cannot book appointments")),
          PendingAppointmentTab(role: widget.role, userId: userId),
          AppointmentHistoryTab(role: widget.role, userId: userId),
        ],
      ),
    );
  }
}

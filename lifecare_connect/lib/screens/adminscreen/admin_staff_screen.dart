// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sharedscreen/staff_list_widget.dart';

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Directory'),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_hospital), text: 'Doctors'),
              Tab(icon: Icon(Icons.people), text: 'CHWs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StaffListWidget(
              viewerRole: 'admin',
              staffRole: 'doctor',
              onTap: _onStaffTap,
            ),
            StaffListWidget(
              viewerRole: 'admin',
              staffRole: 'chw',
              onTap: _onStaffTap,
            ),
          ],
        ),
      ),
    );
  }

  static void _onStaffTap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    debugPrint('Tapped: ${data['fullName'] ?? 'Unnamed'}');
  }
}

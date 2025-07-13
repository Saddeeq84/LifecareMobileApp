import 'package:flutter/material.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('List of Doctors and CHWs will appear here.'),
      ),
    );
  }
}
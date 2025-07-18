import 'package:flutter/material.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
// This screen is a placeholder for future admin messaging features.
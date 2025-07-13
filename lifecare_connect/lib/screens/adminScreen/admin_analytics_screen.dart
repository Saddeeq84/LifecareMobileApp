import 'package:flutter/material.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Analytics Screen'),
      ),
    );
  }
}
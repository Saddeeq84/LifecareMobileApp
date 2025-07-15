import 'package:flutter/material.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Referrals'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Referrals Screen'),
      ),
    );
  }
}
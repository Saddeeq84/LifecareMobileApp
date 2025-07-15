import 'package:flutter/material.dart';

class MyHealthRecordDetails extends StatelessWidget {
  final String userUid;
  final String recordId;
  final String recordDescription;

  const MyHealthRecordDetails({
    super.key,
    required this.userUid,
    required this.recordId,
    required this.recordDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Record Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record ID: $recordId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Description: $recordDescription'),
            const SizedBox(height: 10),
            Text('User UID: $userUid'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
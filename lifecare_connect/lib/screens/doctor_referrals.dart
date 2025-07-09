import 'package:flutter/material.dart';

class DoctorReferralsScreen extends StatelessWidget {
  const DoctorReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> referrals = [
      {
        'patient': 'Aliyu Musa',
        'reason': 'Suspected Malaria',
        'from': 'CHW: Amina Ibrahim',
        'status': 'Pending'
      },
      {
        'patient': 'Grace John',
        'reason': 'High BP during PNC',
        'from': 'CHW: Zainab Ali',
        'status': 'Responded'
      },
      {
        'patient': 'Usman Bello',
        'reason': 'Prolonged cough',
        'from': 'CHW: Musa Abdullahi',
        'status': 'Pending'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: referrals.length,
        itemBuilder: (context, index) {
          final referral = referrals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(referral['patient']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason: ${referral['reason']}'),
                  Text('From: ${referral['from']}'),
                  Text(
                    'Status: ${referral['status']}',
                    style: TextStyle(
                      color: referral['status'] == 'Pending' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to referral detail screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorReferralDetailScreen(
                      patientName: referral['patient']!,
                      reason: referral['reason']!,
                      submittedBy: referral['from']!,
                      status: referral['status']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
class DoctorReferralDetailScreen extends StatelessWidget {
  final String patientName;
  final String reason;
  final String submittedBy;
  final String status;

  const DoctorReferralDetailScreen({
    super.key,
    required this.patientName,
    required this.reason,
    required this.submittedBy,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$patientName - Referral Detail'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient Name: $patientName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Reason for Referral: $reason', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Submitted By: $submittedBy', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Status: $status', style: TextStyle(fontSize: 16, color: status == 'Pending' ? Colors.orange : Colors.green)),
          ],
        ),
      ),
    );
  }
}
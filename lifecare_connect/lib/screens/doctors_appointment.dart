import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  final List<Map<String, String>> mockAppointments = const [
    {
      'patient': 'Aisha Musa',
      'type': 'Teleconsultation',
      'date': '2025-08-02',
      'time': '10:00 AM',
      'status': 'Confirmed',
    },
    {
      'patient': 'John Doe',
      'type': 'Follow-up',
      'date': '2025-08-03',
      'time': '2:00 PM',
      'status': 'Pending',
    },
    {
      'patient': 'Grace Ojo',
      'type': 'In-person',
      'date': '2025-08-05',
      'time': '11:30 AM',
      'status': 'Cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockAppointments.length,
        separatorBuilder: (_, __) => const Divider(height: 25),
        itemBuilder: (context, index) {
          final appt = mockAppointments[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            tileColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              appt['patient']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${appt['type']}'),
                Text('Date: ${appt['date']} at ${appt['time']}'),
                Text(
                  'Status: ${appt['status']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: getStatusColor(appt['status']),
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600),
            onTap: () {
              // Optional: Navigate to appointment details
              // Navigator.push(...);
            },
          );
        },
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

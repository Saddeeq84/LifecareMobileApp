// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class DoctorConsultationDetailScreen extends StatefulWidget {
  final String patientName;
  final String condition;
  final String submittedBy;
  final String date;
  final String notes;

  const DoctorConsultationDetailScreen({
    super.key,
    required this.patientName,
    required this.condition,
    required this.submittedBy,
    required this.date,
    required this.notes,
  });

  @override
  State<DoctorConsultationDetailScreen> createState() => _DoctorConsultationDetailScreenState();
}

class _DoctorConsultationDetailScreenState extends State<DoctorConsultationDetailScreen> {
  final responseController = TextEditingController();
  bool loading = false;

  void submitResponse() {
    if (responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response')),
      );
      return;
    }

    setState(() => loading = true);

    // Simulate submitting response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation response sent')),
      );
      Navigator.pop(context); // go back to consultations list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Detail'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              widget.patientName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Condition: ${widget.condition}'),
            Text('Submitted by: ${widget.submittedBy}'),
            Text('Date: ${widget.date}'),
            const Divider(height: 32),

            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.notes),
            const SizedBox(height: 24),

            const Text('Your Response:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: responseController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your medical advice or follow-up here...',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loading ? null : submitResponse,
              icon: const Icon(Icons.send),
              label: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Response'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

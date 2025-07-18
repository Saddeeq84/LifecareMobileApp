import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sharedscreen/doctor_list_widget.dart';

class CHWReferPatientScreen extends StatefulWidget {
  const CHWReferPatientScreen({super.key});

  @override
  State<CHWReferPatientScreen> createState() => _CHWReferPatientScreenState();
}

class _CHWReferPatientScreenState extends State<CHWReferPatientScreen> {
  String? selectedDoctorId;
  String? selectedDoctorName;
  final TextEditingController _patientNameCtrl = TextEditingController();

  void _handleDoctorSelected(String doctorId, String doctorName) {
    setState(() {
      selectedDoctorId = doctorId;
      selectedDoctorName = doctorName;
    });
  }

  void _submitReferral() {
    final patientName = _patientNameCtrl.text.trim();

    if (patientName.isEmpty || selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name and select a doctor')),
      );
      return;
    }

    // 🟢 TODO: Submit referral to backend or state management
    // Example: sendReferral(patientName, selectedDoctorId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patient "$patientName" referred to Dr. $selectedDoctorName')),
    );

    // Reset form
    _patientNameCtrl.clear();
    setState(() {
      selectedDoctorId = null;
      selectedDoctorName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer Patient to Doctor'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧑‍🍼 Patient Name
            TextFormField(
              controller: _patientNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 🩺 Doctor List (with selection)
            Expanded(
              child: DoctorListWidget(
                viewerRole: 'chw', // Provide the appropriate role, e.g., 'chw'
                onDoctorTap: (DocumentSnapshot<Object?> doctorSnapshot) {
                  final doctorId = doctorSnapshot.id;
                  final doctorName = doctorSnapshot['name'] ?? '';
                  _handleDoctorSelected(doctorId, doctorName);
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🚀 Refer Button
            ElevatedButton.icon(
              onPressed: _submitReferral,
              icon: const Icon(Icons.send),
              label: const Text('Submit Referral'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

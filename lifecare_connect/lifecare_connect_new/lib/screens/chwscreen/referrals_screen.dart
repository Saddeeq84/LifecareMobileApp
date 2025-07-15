import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPatientId;
  String? reason;
  String urgency = 'Normal';

  List<QueryDocumentSnapshot> patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final chwId = FirebaseAuth.instance.currentUser?.uid;
    if (chwId == null) {
      // Handle unauthenticated state if necessary
      return;
    }

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('chwId', isEqualTo: chwId)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        patients = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patients: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReferral() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedPatientId == null) return;

    final chwId = FirebaseAuth.instance.currentUser?.uid;
    if (chwId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get CHW details
      final chwDoc = await FirebaseFirestore.instance.collection('users').doc(chwId).get();
      final chwName = chwDoc.data()?['name'] ?? 'CHW';

      // Get patient document for selectedPatientId
      final patientDoc = patients.firstWhere((doc) => doc.id == selectedPatientId);

      final referralData = {
        'patientId': selectedPatientId,
        'patientName': patientDoc['name'],
        'chwId': chwId,
        'reason': reason,
        'urgency': urgency,
        'status': 'Pending',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // Add referral
      await FirebaseFirestore.instance.collection('referrals').add(referralData);

            // Notify facility user if facilityUserId exists
      final patientData = patientDoc.data() as Map<String, dynamic>?;
      final facilityUserId = (patientData != null && patientData.containsKey('facilityUserId'))
          ? patientData['facilityUserId']
          : null;

      if (facilityUserId != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'toUserId': facilityUserId,
          'title': 'New Patient Referral',
          'body': 'You have a new referral from $chwName',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Referral submitted')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting referral: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Referrals & Teleconsult"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading && patients.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedPatientId,
                      decoration: const InputDecoration(labelText: "Select Patient"),
                      items: patients
                          .map((doc) => DropdownMenuItem(
                                value: doc.id,
                                child: Text(doc['name'] ?? 'Unknown'),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedPatientId = value),
                      validator: (value) => value == null ? 'Choose a patient' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Referral Reason"),
                      onChanged: (val) => reason = val,
                      validator: (val) => val == null || val.isEmpty ? 'Enter reason' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: urgency,
                      decoration: const InputDecoration(labelText: "Urgency Level"),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => urgency = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Submit Referral"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: _submitReferral,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacilityBookingScreen extends StatefulWidget {
  final String facilityId;
  final Map<String, dynamic> facilityData;

  const FacilityBookingScreen({
    super.key,
    required this.facilityId,
    required this.facilityData,
  });

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  String? _selectedServiceType;
  final TextEditingController _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Request'),
        content: const Text('Do you want to submit this service request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Submit')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    final booking = {
      'patientId': user.uid,
      'facilityId': widget.facilityId,
      'facilityName': widget.facilityData['name'] ?? '',
      'serviceType': _selectedServiceType,
      'notes': _notesCtrl.text.trim(),
      'status': 'pending', // default status
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('bookings').add(booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit request. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.facilityData['services'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Service at ${widget.facilityData['name']}'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Service:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              items: services.entries
                  .where((e) => e.value == true)
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(_labelFromKey(e.key))))
                  .toList(),
              onChanged: (v) => setState(() => _selectedServiceType = v),
              value: _selectedServiceType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Notes (optional):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Any specific instructions or comments?',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Submit Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFromKey(String key) {
    switch (key) {
      case 'lab_test':
        return 'Laboratory Test';
      case 'medicine_delivery':
        return 'Medicine Delivery';
      case 'scan':
        return 'Scan';
      case 'hospital_appointment':
        return 'Hospital Appointment';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }
}
// -------------------- End of Facility Booking Screen --------------------
// This code provides a booking screen for facilities, allowing users to select services and submit requests.
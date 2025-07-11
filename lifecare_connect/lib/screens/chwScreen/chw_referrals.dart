import 'package:flutter/material.dart';

class CHWReferralsScreen extends StatefulWidget {
  const CHWReferralsScreen({super.key});

  @override
  State<CHWReferralsScreen> createState() => _CHWReferralsScreenState();
}

class _CHWReferralsScreenState extends State<CHWReferralsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController reasonController = TextEditingController();
  String? selectedPatient;
  String? selectedDoctor;
  String? selectedFacility;
  String referralType = 'Facility Referral';

  final List<String> dummyPatients = ['Amina Musa', 'Fatima Bello', 'Grace John'];
  final List<String> dummyFacilities = ['General Hospital Tula', 'PHC Kaltungo', 'Cottage Hospital Bambam'];
  final List<String> dummyDoctors = ['Dr. Yusuf Adamu', 'Dr. Grace Okoro', 'Dr. Bashir Ibrahim'];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void _submitReferral() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral submitted')),
      );

      _formKey.currentState!.reset();
      setState(() {
        selectedPatient = null;
        selectedDoctor = null;
        selectedFacility = null;
        referralType = 'Facility Referral';
        reasonController.clear();
      });
    }
  }

  Widget _buildReferralTargetDropdown() {
    if (referralType == 'Facility Referral') {
      return DropdownButtonFormField<String>(
        value: selectedFacility,
        isExpanded: true,
        items: dummyFacilities.map((facility) {
          return DropdownMenuItem(
            value: facility,
            child: Text(facility),
          );
        }).toList(),
        onChanged: (val) => setState(() => selectedFacility = val),
        decoration: const InputDecoration(
          labelText: 'Select Health Facility',
          prefixIcon: Icon(Icons.local_hospital),
        ),
        validator: (val) => val == null ? 'Please select a facility' : null,
      );
    } else {
      return DropdownButtonFormField<String>(
        value: selectedDoctor,
        isExpanded: true,
        items: dummyDoctors.map((doc) {
          return DropdownMenuItem(
            value: doc,
            child: Text(doc),
          );
        }).toList(),
        onChanged: (val) => setState(() => selectedDoctor = val),
        decoration: const InputDecoration(
          labelText: 'Select Doctor',
          prefixIcon: Icon(Icons.person),
        ),
        validator: (val) => val == null ? 'Please select a doctor' : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals & Teleconsult'),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Patient Dropdown
              DropdownButtonFormField<String>(
                value: selectedPatient,
                isExpanded: true,
                items: dummyPatients.map((patient) {
                  return DropdownMenuItem(
                    value: patient,
                    child: Text(patient),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedPatient = val),
                decoration: const InputDecoration(
                  labelText: 'Select Patient',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null ? 'Please select a patient' : null,
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Referral',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please provide a reason' : null,
              ),
              const SizedBox(height: 16),

              // Referral Type Dropdown
              DropdownButtonFormField<String>(
                value: referralType,
                items: const [
                  DropdownMenuItem(value: 'Facility Referral', child: Text('Facility Referral')),
                  DropdownMenuItem(value: 'Teleconsultation', child: Text('Teleconsultation')),
                ],
                onChanged: (value) {
                  setState(() {
                    referralType = value!;
                    selectedDoctor = null;
                    selectedFacility = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Referral Type',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
              ),
              const SizedBox(height: 16),

              // Doctor or Facility dropdown based on selection
              _buildReferralTargetDropdown(),
              const SizedBox(height: 24),

              // Submit
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Referral'),
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
// This screen allows CHWs to submit referrals for patients, either to a health facility or for teleconsultation.
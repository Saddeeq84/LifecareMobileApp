import 'package:flutter/material.dart';

class CHWReferralFormScreen extends StatefulWidget {
  const CHWReferralFormScreen({super.key});

  @override
  State<CHWReferralFormScreen> createState() => _CHWReferralFormScreenState();
}

class _CHWReferralFormScreenState extends State<CHWReferralFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedPatient;
  String referralType = 'Facility';
  String? selectedFacility;
  String? selectedDoctor;
  final reasonController = TextEditingController();

  final List<String> dummyPatients = [
    'Amina Musa',
    'Fatima Bello',
    'Grace John',
  ];

  final List<String> dummyFacilities = [
    'General Hospital Tula',
    'PHC Kaltungo',
    'Cottage Hospital Bambam',
  ];

  final List<String> dummyDoctors = [
    'Dr. Yusuf Adamu',
    'Dr. Grace Okoro',
    'Dr. Bashir Ibrahim',
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate() &&
        selectedPatient != null &&
        ((referralType == 'Facility' && selectedFacility != null) ||
            (referralType == 'Doctor' && selectedDoctor != null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral submitted successfully')),
      );

      setState(() {
        selectedPatient = null;
        selectedFacility = null;
        selectedDoctor = null;
        referralType = 'Facility';
        reasonController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral & Teleconsult'),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Patient',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownMenu<String>(
                width: MediaQuery.of(context).size.width - 48,
                initialSelection: selectedPatient,
                hintText: 'Choose a patient',
                dropdownMenuEntries: dummyPatients
                    .map((e) => DropdownMenuEntry(value: e, label: e))
                    .toList(),
                onSelected: (val) => setState(() => selectedPatient = val),
              ),
              const SizedBox(height: 20),

              const Text(
                'Referral Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              ListTile(
                title: const Text('Health Facility'),
                leading: Radio<String>(
                  value: 'Facility',
                  groupValue: referralType,
                  onChanged: (val) {
                    setState(() {
                      referralType = val!;
                      selectedFacility = null;
                      selectedDoctor = null;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Doctor'),
                leading: Radio<String>(
                  value: 'Doctor',
                  groupValue: referralType,
                  onChanged: (val) {
                    setState(() {
                      referralType = val!;
                      selectedFacility = null;
                      selectedDoctor = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              Text(
                referralType == 'Facility' ? 'Select Facility' : 'Select Doctor',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (referralType == 'Facility')
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width - 48,
                  initialSelection: selectedFacility,
                  hintText: 'Choose facility',
                  dropdownMenuEntries: dummyFacilities
                      .map((e) => DropdownMenuEntry(value: e, label: e))
                      .toList(),
                  onSelected: (val) => setState(() => selectedFacility = val),
                )
              else
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width - 48,
                  initialSelection: selectedDoctor,
                  hintText: 'Choose doctor',
                  dropdownMenuEntries: dummyDoctors
                      .map((e) => DropdownMenuEntry(value: e, label: e))
                      .toList(),
                  onSelected: (val) => setState(() => selectedDoctor = val),
                ),

              const SizedBox(height: 20),
              const Text(
                'Reason for Referral',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Referral'),
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Note: Ensure you have the necessary imports for your screens and any other dependencies.
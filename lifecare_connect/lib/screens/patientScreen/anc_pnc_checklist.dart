import 'package:flutter/material.dart';

class ANCChecklistScreen extends StatefulWidget {
  const ANCChecklistScreen({super.key});

  @override
  State<ANCChecklistScreen> createState() => _ANCChecklistScreenState();
}

class _ANCChecklistScreenState extends State<ANCChecklistScreen> {
  final _formKey = GlobalKey<FormState>();

  bool bloodPressureChecked = false;
  bool ironSupplementGiven = false;
  bool dangerSignsObserved = false;
  bool tetanusVaccineGiven = false;
  bool breastfeedingSupport = false;

  String visitType = 'ANC'; // or PNC
  final notesController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist submitted (UI only)')),
      );
      // Simulate form reset
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          bloodPressureChecked = false;
          ironSupplementGiven = false;
          dangerSignsObserved = false;
          tetanusVaccineGiven = false;
          breastfeedingSupport = false;
          notesController.clear();
        });
      });
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANC / PNC Checklist'),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Select Visit Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: visitType,
                items: const [
                  DropdownMenuItem(value: 'ANC', child: Text('Antenatal (ANC)')),
                  DropdownMenuItem(value: 'PNC', child: Text('Postnatal (PNC)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => visitType = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Checklist Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Blood Pressure Checked'),
                value: bloodPressureChecked,
                onChanged: (value) => setState(() => bloodPressureChecked = value!),
              ),
              CheckboxListTile(
                title: const Text('Iron Supplements Given'),
                value: ironSupplementGiven,
                onChanged: (value) => setState(() => ironSupplementGiven = value!),
              ),
              CheckboxListTile(
                title: const Text('Any Danger Signs Observed'),
                value: dangerSignsObserved,
                onChanged: (value) => setState(() => dangerSignsObserved = value!),
              ),
              CheckboxListTile(
                title: const Text('Tetanus Vaccine Given'),
                value: tetanusVaccineGiven,
                onChanged: (value) => setState(() => tetanusVaccineGiven = value!),
              ),
              CheckboxListTile(
                title: const Text('Breastfeeding Support Provided'),
                value: breastfeedingSupport,
                onChanged: (value) => setState(() => breastfeedingSupport = value!),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Submit Checklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This code defines a Flutter screen for an ANC/PNC checklist form.
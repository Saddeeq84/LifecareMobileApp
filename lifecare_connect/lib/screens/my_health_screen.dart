import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MyHealthScreen extends StatefulWidget {
  const MyHealthScreen({super.key});

  @override
  State<MyHealthScreen> createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> {
  Map<String, String> selfReportedVitals = {};
  List<String> uploadedLabResults = [];

  void _uploadLabResult(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        uploadedLabResults.add(result.files.single.name);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lab result "${result.files.single.name}" uploaded!')),
      );
    }
  }

  void _showAddVitalsDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final Map<String, String> tempVitals = {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Vitals'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildVitalsField('BP', 'e.g., 120/80', tempVitals),
                  _buildVitalsField('HR', 'Heart Rate (bpm)', tempVitals),
                  _buildVitalsField('Temp', 'Temperature (°C)', tempVitals),
                  _buildVitalsField('SpO₂', 'Oxygen Saturation (%)', tempVitals),
                  _buildVitalsField('Glucose', 'Blood Glucose (mg/dL)', tempVitals),
                  _buildVitalsField('Weight', 'Weight (kg)', tempVitals),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                formKey.currentState?.save();
                setState(() {
                  selfReportedVitals = Map.from(tempVitals);
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVitalsField(String key, String hint, Map<String, String> store) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(labelText: key, hintText: hint),
        onSaved: (value) => store[key] = value ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("Health Conditions", Icons.local_hospital),
          _buildListCard(["Hypertension", "Diabetes (Type 2)"]),

          _buildSectionTitle("Vital Signs (Doctor's Records)", Icons.monitor_heart),
          _buildVitalsCard(),
          _buildAddVitalsButton(context),

          _buildSectionTitle("Lab Results", Icons.science),
          _buildUploadButton(context),
          _buildListCard([
            ...uploadedLabResults,
            "FBC - Normal (2024-06-01)",
            "Malaria Parasite - Negative (2024-05-18)"
          ]),

          _buildSectionTitle("Medications (Doctor's Prescription)", Icons.medication_outlined),
          _buildListCard([
            "Amlodipine 5mg — 1 tablet daily",
            "Metformin 500mg — 2 tablets daily",
          ]),

          _buildSectionTitle("Vaccination History", Icons.vaccines),
          _buildListCard([
            "COVID-19 (2 doses, 2021)",
            "Tetanus (2022)",
          ]),

          _buildSectionTitle("Allergies", Icons.warning_amber_outlined),
          _buildListCard([
            "No known drug allergies",
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal.shade700),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsCard() {
    return Card(
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("From Doctor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _vitalItem("BP", "140/90"),
                _vitalItem("HR", "78 bpm"),
                _vitalItem("Temp", "36.5°C"),
                _vitalItem("SpO₂", "98%"),
                _vitalItem("Glucose", "110 mg/dL"),
                _vitalItem("Weight", "68 kg"),
              ],
            ),
            if (selfReportedVitals.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("Self-Reported", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: selfReportedVitals.entries.map((entry) {
                  return _vitalItem(entry.key, entry.value);
                }).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _vitalItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildListCard(List<String> items) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          return Text(
            "• ${items[index]}",
            style: const TextStyle(fontSize: 15),
          );
        },
      ),
    );
  }

  Widget _buildAddVitalsButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _showAddVitalsDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Vitals"),
        style: TextButton.styleFrom(foregroundColor: Colors.teal),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _uploadLabResult(context),
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload New Lab Result"),
        style: TextButton.styleFrom(foregroundColor: Colors.teal),
      ),
    );
  }
}
// This screen displays the patient's health information, including conditions, vitals, lab results, medications, vaccinations, and allergies.
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MyUnifiedHealthScreen extends StatefulWidget {
  const MyUnifiedHealthScreen({super.key});

  @override
  State<MyUnifiedHealthScreen> createState() => _MyUnifiedHealthScreenState();
}

class _MyUnifiedHealthScreenState extends State<MyUnifiedHealthScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, String> selfReportedVitals = {};
  List<String> uploadedLabResults = [];

  void _uploadLocalLabResult(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        uploadedLabResults.add(result.files.single.name);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lab result "${result.files.single.name}" uploaded locally!')),
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
    if (currentUser == null) {
      return const Center(child: Text('User not logged in.'));
    }

    final healthRecordsRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(currentUser!.uid)
        .collection('health_records')
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("My Health Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: healthRecordsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle("Health Records", Icons.folder_shared),
              if (docs.isEmpty)
                const Text("No health records found.")
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp?)?.toDate();
                  final description = data['description'] ?? 'No description';
                  final value = data['value'] ?? '';
                  return Card(
                    child: ListTile(
                      title: Text(description),
                      subtitle: Text("Value: $value\nDate: ${date?.toLocal().toString().split(' ')[0] ?? 'Unknown'}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HealthRecordDetailPage(
                              userUid: currentUser!.uid,
                              recordId: doc.id,
                              recordDescription: description,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

              _buildSectionTitle("Self-Reported Vitals", Icons.monitor_heart),
              _buildVitalsCard(),
              _buildAddVitalsButton(context),

              _buildSectionTitle("Local Lab Uploads", Icons.upload_file),
              _buildUploadButton(context),
              _buildListCard(uploadedLabResults),
            ],
          );
        },
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
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal.shade700)),
        ],
      ),
    );
  }

  Widget _buildVitalsCard() {
    if (selfReportedVitals.isEmpty) {
      return const Text("No self-reported vitals yet.");
    }
    return Card(
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 10,
          children: selfReportedVitals.entries.map((entry) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(entry.key, style: const TextStyle(color: Colors.grey)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListCard(List<String> items) {
    if (items.isEmpty) return const Text("No items uploaded yet.");
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          return Text("• ${items[index]}", style: const TextStyle(fontSize: 15));
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
        onPressed: () => _uploadLocalLabResult(context),
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload New Lab Result"),
        style: TextButton.styleFrom(foregroundColor: Colors.teal),
      ),
    );
  }
}

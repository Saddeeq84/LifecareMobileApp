// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifecare_connect/screens/patientscreen/my_health_record_details.dart';
import '../../services/health_records_service.dart';

class MyHealthTab extends StatefulWidget {
  const MyHealthTab({super.key});

  @override
  State<MyHealthTab> createState() => _MyHealthTabState();
}

class _MyHealthTabState extends State<MyHealthTab> {
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  // Filter out empty values
                  final filteredVitals = Map<String, dynamic>.from(tempVitals)
                    ..removeWhere((key, value) => value.isEmpty);
                  
                  if (filteredVitals.isNotEmpty && currentUser != null) {
                    try {
                      await HealthRecordsService.saveSelfReportedVitals(
                        patientUid: currentUser!.uid,
                        vitalsData: filteredVitals,
                      );
                      
                      setState(() {
                        selfReportedVitals = Map.from(filteredVitals);
                      });
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vitals saved to your health records'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving vitals: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save to Health Records'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Health Dashboard"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Centralized Health Records
            StreamBuilder<QuerySnapshot>(
              stream: HealthRecordsService.getPatientHealthRecords(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                
                final docs = snapshot.data?.docs ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("My Health Records", Icons.folder_shared),
                    if (docs.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No health records found. Your CHW or doctor visits will appear here."),
                        ),
                      )
                    else
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final recordType = data['type'] ?? 'Unknown';
                        final date = (data['date'] as Timestamp?)?.toDate();
                        final providerName = data['providerName'] ?? 'Unknown Provider';
                        final providerType = data['providerType'] ?? '';
                        
                        // Get specific info based on record type
                        String subtitle = '';
                        IconData icon = Icons.medical_information;
                        
                        if (recordType == 'ANC_VISIT') {
                          final ancData = data['data'] as Map<String, dynamic>? ?? {};
                          final bp = ancData['bloodPressure'] ?? 'N/A';
                          final weight = ancData['weight'] ?? 'N/A';
                          subtitle = 'BP: $bp | Weight: ${weight}kg';
                          icon = Icons.pregnant_woman;
                        } else if (recordType == 'SELF_REPORTED_VITALS') {
                          subtitle = 'Self-reported vital signs';
                          icon = Icons.monitor_heart;
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Icon(icon, color: Colors.teal),
                            ),
                            title: Text(
                              recordType.replaceAll('_', ' '),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subtitle),
                                Text(
                                  'By: $providerName ($providerType)',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Date: ${date?.toLocal().toString().split(' ')[0] ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyHealthRecordDetails(
                                    recordId: doc.id,
                                    recordType: recordType,
                                  ),
                                ),
                              );
                            },
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Self-Reported Vitals", Icons.monitor_heart),
            _buildVitalsCard(),
            _buildAddVitalsButton(context),

            const SizedBox(height: 20),
            _buildSectionTitle("Local Lab Uploads", Icons.upload_file),
            _buildUploadButton(context),
            _buildListCard(uploadedLabResults),
          ],
        ),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal.shade700),
          ),
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

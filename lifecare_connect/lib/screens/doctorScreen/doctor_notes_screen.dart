// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorNotesScreen extends StatefulWidget {
  const DoctorNotesScreen({super.key});

  @override
  State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
}

class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
  void _openAddNoteForm({String? preselectedPatient}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalNoteScreen(
          preselectedPatient: preselectedPatient,
        ),
      ),
    );
  }

  void _viewNoteDetail(DocumentSnapshot noteDoc) {
    final noteData = noteDoc.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewMedicalNoteScreen(
          note: noteData,
          onAddNote: () => _openAddNoteForm(preselectedPatient: noteData["patient"]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Notes"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notes').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes available."));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(note["patient"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${note["age"]} yrs • ${note["gender"]} • ${note["condition"]}"),
                      const SizedBox(height: 4),
                      Text(
                        (note["note"] ?? "").length > 50
                            ? "${note["note"].substring(0, 50)}..."
                            : note["note"] ?? "",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  trailing: Text(note["date"] ?? ""),
                  onTap: () => _viewNoteDetail(notes[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddNoteForm(),
        child: const Icon(Icons.note_add),
        tooltip: "Add Note",
      ),
    );
  }
}

class AddMedicalNoteScreen extends StatefulWidget {
  final String? preselectedPatient;

  const AddMedicalNoteScreen({super.key, this.preselectedPatient});

  @override
  State<AddMedicalNoteScreen> createState() => _AddMedicalNoteScreenState();
}

class _AddMedicalNoteScreenState extends State<AddMedicalNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  final _customLabCtrl = TextEditingController();
  final _customMedCtrl = TextEditingController();
  final _customScanCtrl = TextEditingController();

  String? selectedPatient;
  Map<String, String>? selectedPatientData;

  final List<Map<String, String>> patientList = [
    {"name": "Fatima Bello", "age": "29", "gender": "Female", "condition": "Preeclampsia"},
    {"name": "John Yusuf", "age": "41", "gender": "Male", "condition": "Hypertension"},
    {"name": "Grace Danjuma", "age": "32", "gender": "Female", "condition": "Diabetes"},
    {"name": "Kabiru Saleh", "age": "37", "gender": "Male", "condition": "Asthma"},
  ];

  final List<String> labTests = ["Blood Count", "Urinalysis", "Malaria Test"];
  final List<String> medications = ["Paracetamol", "Lisinopril", "Metformin"];
  final List<String> scans = ["Ultrasound", "X-ray", "MRI"];

  String? selectedLab;
  String? selectedMed;
  String? selectedScan;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedPatient != null) {
      selectedPatientData = patientList.firstWhere(
        (p) => p["name"] == widget.preselectedPatient,
        orElse: () => {"name": widget.preselectedPatient!, "age": "", "gender": "", "condition": ""},
      );
      selectedPatient = selectedPatientData!["name"];
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _customLabCtrl.dispose();
    _customMedCtrl.dispose();
    _customScanCtrl.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate() && selectedPatientData != null) {
      String combinedNote = _noteCtrl.text.trim();
      if (selectedLab != null || _customLabCtrl.text.isNotEmpty) {
        combinedNote += "\n\n🧪 Lab Test: ${selectedLab ?? ''} ${_customLabCtrl.text}";
      }
      if (selectedMed != null || _customMedCtrl.text.isNotEmpty) {
        combinedNote += "\n\n💊 Medication: ${selectedMed ?? ''} ${_customMedCtrl.text}";
      }
      if (selectedScan != null || _customScanCtrl.text.isNotEmpty) {
        combinedNote += "\n\n🖥️ Scan Request: ${selectedScan ?? ''} ${_customScanCtrl.text}";
      }

      await FirebaseFirestore.instance.collection("notes").add({
        "patient": selectedPatientData!["name"] ?? "",
        "age": selectedPatientData!["age"] ?? "",
        "gender": selectedPatientData!["gender"] ?? "",
        "condition": selectedPatientData!["condition"] ?? "",
        "note": combinedNote,
        "date": DateTime.now().toString().split(' ')[0],
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPreselected = widget.preselectedPatient != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medical Note"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isPreselected)
                DropdownButtonFormField<String>(
                  value: selectedPatient,
                  items: patientList.map((p) {
                    return DropdownMenuItem(
                      value: p["name"],
                      child: Text(p["name"]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPatient = value;
                      selectedPatientData = patientList.firstWhere((p) => p["name"] == value);
                    });
                  },
                  decoration: const InputDecoration(labelText: "Select Patient"),
                  validator: (val) => val == null ? "Please select a patient" : null,
                ),
              if (isPreselected)
                TextFormField(
                  initialValue: selectedPatient,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Patient"),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Clinical Note",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Note is required" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedLab,
                items: labTests.map((test) => DropdownMenuItem(value: test, child: Text(test))).toList(),
                onChanged: (val) => setState(() => selectedLab = val),
                decoration: const InputDecoration(labelText: "Select Lab Test (optional)"),
              ),
              TextFormField(
                controller: _customLabCtrl,
                decoration: const InputDecoration(labelText: "Other Lab Test"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedMed,
                items: medications.map((med) => DropdownMenuItem(value: med, child: Text(med))).toList(),
                onChanged: (val) => setState(() => selectedMed = val),
                decoration: const InputDecoration(labelText: "Prescribe Medicine (optional)"),
              ),
              TextFormField(
                controller: _customMedCtrl,
                decoration: const InputDecoration(labelText: "Other Medication"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedScan,
                items: scans.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedScan = val),
                decoration: const InputDecoration(labelText: "Request Scan (optional)"),
              ),
              TextFormField(
                controller: _customScanCtrl,
                decoration: const InputDecoration(labelText: "Other Scan Type"),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save),
                label: const Text("Save Note"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewMedicalNoteScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onAddNote;

  const ViewMedicalNoteScreen({
    super.key,
    required this.note,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final String patientName = note["patient"] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: Text("Note - $patientName"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient: $patientName", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Age: ${note["age"]}"),
            Text("Gender: ${note["gender"]}"),
            Text("Condition: ${note["condition"]}"),
            const SizedBox(height: 8),
            Text("Date: ${note["date"]}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Text(note["note"] ?? "", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add new note for $patientName",
        child: const Icon(Icons.note_add),
        onPressed: onAddNote,
      ),
    );
  }
}

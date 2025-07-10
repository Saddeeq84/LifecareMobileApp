// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';

class DoctorNotesScreen extends StatefulWidget {
  const DoctorNotesScreen({super.key});

  @override
  State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
}

class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
  List<Map<String, String>> notes = [
    {
      "patient": "Fatima Bello",
      "age": "29",
      "gender": "Female",
      "condition": "Preeclampsia",
      "note": "Patient presents with signs of preeclampsia. BP elevated. Advised urgent scan.",
      "date": "2025-07-10"
    },
  ];

  void _openAddNoteForm({String? preselectedPatient}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalNoteScreen(
          preselectedPatient: preselectedPatient,
          onSave: (newNote) {
            setState(() {
              notes.insert(0, newNote);
            });
          },
        ),
      ),
    );
  }

  void _viewNoteDetail(Map<String, String> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewMedicalNoteScreen(
          note: note,
          onAddNote: () => _openAddNoteForm(preselectedPatient: note["patient"]),
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
      body: notes.isEmpty
          ? const Center(child: Text("No notes available."))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
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
                              ? "${note["note"]!.substring(0, 50)}..."
                              : note["note"] ?? "",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    trailing: Text(note["date"] ?? ""),
                    onTap: () => _viewNoteDetail(note),
                  ),
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
  final Function(Map<String, String>) onSave;
  final String? preselectedPatient;

  const AddMedicalNoteScreen({
    super.key,
    required this.onSave,
    this.preselectedPatient,
  });

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

  void _saveNote() {
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

      widget.onSave({
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

              // Lab test
              DropdownButtonFormField<String>(
                value: selectedLab,
                items: labTests.map((test) {
                  return DropdownMenuItem(value: test, child: Text(test));
                }).toList(),
                onChanged: (val) => setState(() => selectedLab = val),
                decoration: const InputDecoration(labelText: "Select Lab Test (optional)"),
              ),
              TextFormField(
                controller: _customLabCtrl,
                decoration: const InputDecoration(labelText: "Other Lab Test"),
              ),
              const SizedBox(height: 20),

              // Medication
              DropdownButtonFormField<String>(
                value: selectedMed,
                items: medications.map((med) {
                  return DropdownMenuItem(value: med, child: Text(med));
                }).toList(),
                onChanged: (val) => setState(() => selectedMed = val),
                decoration: const InputDecoration(labelText: "Prescribe Medicine (optional)"),
              ),
              TextFormField(
                controller: _customMedCtrl,
                decoration: const InputDecoration(labelText: "Other Medication"),
              ),
              const SizedBox(height: 20),

              // Scan
              DropdownButtonFormField<String>(
                value: selectedScan,
                items: scans.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
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
  final Map<String, String> note;
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

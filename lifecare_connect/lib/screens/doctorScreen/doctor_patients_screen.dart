import 'package:flutter/material.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  List<Map<String, dynamic>> patients = [
    {
      "name": "Fatima Bello",
      "age": 29,
      "gender": "Female",
      "condition": "Pregnancy - High Risk",
      "id": "PT-1001"
    },
    {
      "name": "John Yusuf",
      "age": 41,
      "gender": "Male",
      "condition": "Hypertension",
      "id": "PT-1002"
    },
    {
      "name": "Grace Danjuma",
      "age": 32,
      "gender": "Female",
      "condition": "Diabetes",
      "id": "PT-1003"
    },
  ];

  String searchQuery = '';
  String genderFilter = 'All';

  List<String> genderOptions = ['All', 'Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPatients = patients
        .where((p) =>
            (searchQuery.isEmpty ||
                p['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
                p['id'].toLowerCase().contains(searchQuery.toLowerCase())) &&
            (genderFilter == 'All' || p['gender'] == genderFilter))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name or ID",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: genderFilter,
                  items: genderOptions
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        genderFilter = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredPatients.isEmpty
                ? const Center(child: Text("No matching patients found."))
                : ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final p = filteredPatients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(p['name']),
                          subtitle: Text(
                              "${p['age']} yrs • ${p['gender']} • ${p['condition']}"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorPatientDetailScreen(patient: p),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DoctorPatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const DoctorPatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient['name']),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient ID: ${patient['id']}",
                style: const TextStyle(fontSize: 16)),
            Text("Age: ${patient['age']}",
                style: const TextStyle(fontSize: 16)),
            Text("Gender: ${patient['gender']}",
                style: const TextStyle(fontSize: 16)),
            Text("Condition: ${patient['condition']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicalHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("View History"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddNoteScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note_add),
                    label: const Text("Add Note"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text("This is the Medical History screen (UI only)."),
      ),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Clinical Note"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write your note here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Note saved (UI only)")),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Note"),
            ),
          ],
        ),
      ),
    );
  }
}
// Note: This code provides a basic structure for the DoctorPatientsScreen and related screens.
// You can expand the functionality by integrating with a backend or database to fetch real patient data,
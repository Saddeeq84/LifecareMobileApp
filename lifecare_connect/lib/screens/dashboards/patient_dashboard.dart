import 'package:flutter/material.dart';
import 'package:lifecare_connect/screens/appointments/patient_appointment_screen.dart';
import 'package:lifecare_connect/screens/patient_education_screen.dart';
import 'package:lifecare_connect/screens/daily_health_tips_screen.dart';
import 'package:lifecare_connect/screens/chat_with_chw_screen.dart';
import 'package:lifecare_connect/screens/patient_messages_screen.dart';
import 'package:lifecare_connect/screens/patient_profile_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  final List<_DashboardPage> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _DashboardPage(title: 'My Health', icon: Icons.health_and_safety_outlined, content: MyHealthTab()),
      _DashboardPage(title: 'Appointments', icon: Icons.calendar_today_outlined, content: const PatientAppointmentsScreen()),
      _DashboardPage(title: 'Education', icon: Icons.school_outlined, content: const PatientEducationScreen()),
      _DashboardPage(title: 'Daily Tips', icon: Icons.tips_and_updates_outlined, content: const DailyHealthTipsScreen()),
      _DashboardPage(title: 'Messages', icon: Icons.chat_bubble_outline, content: const PatientMessagesScreen()),
      _DashboardPage(title: 'Chat', icon: Icons.chat_outlined, content: const ChatWithCHWScreen()),
      _DashboardPage(title: 'Services', icon: Icons.medical_services_outlined, content: const PatientServicesTab()),
      _DashboardPage(title: 'Profile', icon: Icons.person_outline, content: const PatientProfileScreen()),
      _DashboardPage(title: 'Settings', icon: Icons.settings_outlined, content: const Center(child: Text("Settings (UI only)"))),
    ]);
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated logout')));
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: currentPage.content),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: _pages.map((page) => BottomNavigationBarItem(icon: Icon(page.icon), label: page.title)).toList(),
      ),
    );
  }
}

class _DashboardPage {
  final String title;
  final IconData icon;
  final Widget content;
  const _DashboardPage({required this.title, required this.icon, required this.content});
}

// -------------------- ▶️ My Health Tab --------------------

class MyHealthTab extends StatelessWidget {
  MyHealthTab({super.key});

  final List<Map<String, String>> notes = const [
    {
      "doctor": "Dr. Amina Yusuf",
      "note": "Preeclampsia suspected. Monitor BP.",
      "lab": "Urinalysis",
      "med": "Labetalol",
      "scan": "Obstetric Ultrasound",
      "date": "2025-07-10"
    },
  ];

  final List<String> doctors = ["Dr. Amina Yusuf", "Dr. Kabiru Musa", "Dr. Grace Danjuma"];

  void _uploadResultToDoctor(BuildContext context) {
    String? selectedDoctor;
    final TextEditingController resultCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Result"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              hint: const Text("Select Doctor"),
              items: doctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc))).toList(),
              onChanged: (value) => selectedDoctor = value,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: resultCtrl,
              decoration: const InputDecoration(labelText: "Result Summary", border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (selectedDoctor != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Result sent to $selectedDoctor (UI only)")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showVitalEntry(BuildContext context) {
    final bpCtrl = TextEditingController();
    final tempCtrl = TextEditingController();
    final glucoseCtrl = TextEditingController();
    final hrCtrl = TextEditingController();
    final rrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Vitals"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: bpCtrl, decoration: const InputDecoration(labelText: "Blood Pressure")),
              TextField(controller: tempCtrl, decoration: const InputDecoration(labelText: "Temperature (°C)")),
              TextField(controller: glucoseCtrl, decoration: const InputDecoration(labelText: "Blood Glucose (mg/dL)")),
              TextField(controller: hrCtrl, decoration: const InputDecoration(labelText: "Heart Rate (bpm)")),
              TextField(controller: rrCtrl, decoration: const InputDecoration(labelText: "Respiratory Rate")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Vitals saved (UI only)")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.upload_file), label: const Text("Upload Result"), onPressed: () => _uploadResultToDoctor(context)),
            ElevatedButton.icon(icon: const Icon(Icons.favorite), label: const Text("Enter Vitals"), onPressed: () => _showVitalEntry(context)),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👨‍⚕️ ${note['doctor']!}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("📅 ${note['date']}"),
                      const Divider(),
                      Text("📝 Note: ${note['note']}"),
                      Text("🧪 Lab: ${note['lab']}"),
                      Text("💊 Medication: ${note['med']}"),
                      Text("🖥️ Scan: ${note['scan']}"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -------------------- ▶️ Services Tab --------------------

class PatientServicesTab extends StatelessWidget {
  const PatientServicesTab({super.key});

  final Map<String, List<Map<String, String>>> facilityData = const {
    "Hospital Appointment": [
      {"name": "Tula Yiri PHC", "location": "Gombe", "type": "Hospital"},
    ],
    "Laboratory Test": [
      {"name": "Federal Lab Gombe", "location": "Gombe", "type": "Laboratory"},
    ],
    "Medication Order": [
      {"name": "Kabri Pharmacy", "location": "Taraba", "type": "Pharmacy"},
    ],
    "Radiology Scan": [
      {"name": "Gombe Scan Center", "location": "Gombe", "type": "Scan Center"},
    ],
  };

  void _showFacilityPicker(BuildContext context, String serviceType) {
    final facilities = facilityData[serviceType] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Text("Select $serviceType", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...facilities.map((f) {
              return ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.green),
                title: Text(f["name"]!),
                subtitle: Text("${f["location"]} • ${f["type"]}"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$serviceType request submitted to ${f["name"]} (UI only)")),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {"label": "Book Hospital", "icon": Icons.local_hospital, "type": "Hospital Appointment", "color": Colors.green},
      {"label": "Lab Test", "icon": Icons.science, "type": "Laboratory Test", "color": Colors.orange},
      {"label": "Order Drugs", "icon": Icons.local_pharmacy, "type": "Medication Order", "color": Colors.purple},
      {"label": "Scan Booking", "icon": Icons.monitor_heart, "type": "Radiology Scan", "color": Colors.teal},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = services[index];
        return ListTile(
          leading: Icon(item["icon"], color: item["color"]),
          title: Text(item["label"]),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showFacilityPicker(context, item["type"]),
        );
      },
    );
  }
}
// -------------------- ▶️ Patient Dashboard --------------------
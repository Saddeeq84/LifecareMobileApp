import 'package:flutter/material.dart';

class DoctorScheduledConsultsScreen extends StatefulWidget {
  const DoctorScheduledConsultsScreen({super.key});

  @override
  State<DoctorScheduledConsultsScreen> createState() => _DoctorScheduledConsultsScreenState();
}

class _DoctorScheduledConsultsScreenState extends State<DoctorScheduledConsultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> upcoming = [
    {
      "name": "Fatima Bello",
      "condition": "Pregnancy - High Risk",
      "datetime": "2025-07-12 10:00 AM"
    },
    {
      "name": "John Yusuf",
      "condition": "Hypertension",
      "datetime": "2025-07-12 11:30 AM"
    },
  ];

  final List<Map<String, String>> pending = [
    {
      "name": "Grace Danjuma",
      "condition": "Diabetes",
      "datetime": "Awaiting Confirmation"
    },
  ];

  final List<Map<String, String>> past = [
    {
      "name": "Kabiru Saleh",
      "condition": "Asthma",
      "datetime": "2025-07-10 2:00 PM"
    },
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildConsultList(List<Map<String, String>> data, {bool showJoin = false}) {
    if (data.isEmpty) {
      return const Center(child: Text("No consultations here."));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final consult = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(consult["name"] ?? ""),
            subtitle: Text("${consult["condition"]} • ${consult["datetime"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showJoin)
                  IconButton(
                    icon: const Icon(Icons.video_call, color: Colors.green),
                    tooltip: "Join Consult",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Launching video call (UI only)")),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: "View Case",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Viewing case details (UI only)")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheduled Consults"),
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Pending"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultList(upcoming, showJoin: true),
          _buildConsultList(pending),
          _buildConsultList(past),
        ],
      ),
    );
  }
}
// Note: This code provides a basic structure for the DoctorScheduledConsultsScreen.
// You can expand the functionality by integrating with a backend or database to fetch real data,
// implementing video call functionality, and adding more features as needed.
// Ensure to handle permissions and video call logic according to your app's requirements.
// You can also customize the UI further to match your app's design language.
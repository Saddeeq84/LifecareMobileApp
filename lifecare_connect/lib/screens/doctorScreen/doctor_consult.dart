import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorScheduledConsultsScreen extends StatefulWidget {
  const DoctorScheduledConsultsScreen({super.key});

  @override
  State<DoctorScheduledConsultsScreen> createState() =>
      _DoctorScheduledConsultsScreenState();
}

class _DoctorScheduledConsultsScreenState
    extends State<DoctorScheduledConsultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  /// Builds the consult list UI from a list of Firestore documents.
  Widget _buildConsultList(List<QueryDocumentSnapshot> consults, bool showJoin) {
    if (consults.isEmpty) {
      return const Center(child: Text("No consultations here."));
    }

    return ListView.builder(
      itemCount: consults.length,
      itemBuilder: (context, index) {
        final data = consults[index].data() as Map<String, dynamic>;
        final name = data['patientName'] ?? 'Unknown';
        final condition = data['condition'] ?? 'Unknown';
        final datetime = data['date'] ?? 'N/A';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(name),
            subtitle: Text('$condition • $datetime'),
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

  /// Fetches and filters consults from Firestore by status.
  Widget _buildConsultTab(String status, {bool showJoin = false}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consults')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No consultations here."));
        }

        return _buildConsultList(snapshot.data!.docs, showJoin);
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
          _buildConsultTab("upcoming", showJoin: true),
          _buildConsultTab("pending"),
          _buildConsultTab("past"),
        ],
      ),
    );
  }
}

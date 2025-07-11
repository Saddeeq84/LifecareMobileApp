import 'package:flutter/material.dart';

class DoctorReferralsScreen extends StatefulWidget {
  const DoctorReferralsScreen({super.key});

  @override
  State<DoctorReferralsScreen> createState() => _DoctorReferralsScreenState();
}

class _DoctorReferralsScreenState extends State<DoctorReferralsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, String>> pendingReferrals = [
    {
      "patient": "Fatima Bello",
      "condition": "Pregnancy - High Risk",
      "chw": "Amina S.",
    },
    {
      "patient": "John Yusuf",
      "condition": "Hypertension",
      "chw": "Bello Musa",
    },
  ];

  List<Map<String, String>> reviewedReferrals = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _handleReferralDecision(
      Map<String, String> referral, String decision) {
    setState(() {
      pendingReferrals.remove(referral);
      reviewedReferrals.add({
        ...referral,
        "status": decision,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Referral $decision")),
    );
  }

  Widget _buildReferralCard(Map<String, String> r,
      {bool isReviewed = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(r["patient"] ?? ""),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Condition: ${r["condition"]}"),
            Text("Referred by: ${r["chw"]}"),
            if (isReviewed) Text("Status: ${r["status"]}"),
          ],
        ),
        trailing: isReviewed
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Accept",
                    onPressed: () => _handleReferralDecision(r, "Accepted"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Reject",
                    onPressed: () => _handleReferralDecision(r, "Rejected"),
                  ),
                ],
              ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("View details for ${r["patient"]}")),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Referrals"),
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Reviewed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          pendingReferrals.isEmpty
              ? const Center(child: Text("No pending referrals."))
              : ListView(
                  children: pendingReferrals
                      .map((r) => _buildReferralCard(r))
                      .toList(),
                ),
          reviewedReferrals.isEmpty
              ? const Center(child: Text("No reviewed referrals yet."))
              : ListView(
                  children: reviewedReferrals
                      .map((r) => _buildReferralCard(r, isReviewed: true))
                      .toList(),
                ),
        ],
      ),
    );
  }
}
// Note: This code provides a basic structure for the DoctorReferralsScreen.
// You can expand the functionality by integrating with a backend or database to fetch real referral data,
// implementing more complex referral management features, and adding more UI enhancements as needed.
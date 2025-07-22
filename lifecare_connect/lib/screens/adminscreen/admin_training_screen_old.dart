import 'package:flutter/material.dart';

class AdminTrainingScreen extends StatefulWidget {
  const AdminTrainingScreen({super.key});

  @override
  State<AdminTrainingScreen> createState() => _AdminTrainingScreenState();
}

class _AdminTrainingScreenState extends State<AdminTrainingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text("Training & Education Management"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: "CHW Training"),
            Tab(icon: Icon(Icons.health_and_safety), text: "Patient Education"),
            Tab(icon: Icon(Icons.video_library), text: "Training Videos"),
            Tab(icon: Icon(Icons.folder), text: "Resources"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComingSoonTab('CHW Training Materials', Icons.school, Colors.deepPurple),
          _buildComingSoonTab('Patient Education Materials', Icons.health_and_safety, Colors.green),
          _buildComingSoonTab('Training Videos', Icons.video_library, Colors.red),
          _buildComingSoonTab('Additional Resources', Icons.folder, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String title, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '$title upload functionality is under development and will be available in a future update.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Icon(
            Icons.construction,
            size: 40,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
  // This file defines the Admin Training screen for the app.

}

class AdminTrainingModulesScreen extends StatefulWidget {
  const AdminTrainingModulesScreen({super.key});

  @override
  State<AdminTrainingModulesScreen> createState() => _AdminTrainingModulesScreenState();
}

class _AdminTrainingModulesScreenState extends State<AdminTrainingModulesScreen> {
  final List<Map<String, String>> modules = [
    {
      "title": "Safe Delivery Practices",
      "audience": "CHW",
      "duration": "15 mins"
    },
    {
      "title": "Understanding ANC Services",
      "audience": "Patients",
      "duration": "20 mins"
    },
    {
      "title": "Referral Protocol Training",
      "audience": "CHW",
      "duration": "30 mins"
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredModules = modules
        .where((module) =>
            module["title"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Modules"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by title",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: filteredModules.isEmpty
                ? const Center(child: Text("No matching training modules found."))
                : ListView.builder(
                    itemCount: filteredModules.length,
                    itemBuilder: (context, index) {
                      final m = filteredModules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.school, color: Colors.deepPurple),
                          title: Text(m["title"]!),
                          subtitle: Text("${m["audience"]} • ${m["duration"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Edit '${m["title"]}' (UI only)")),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Module",
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add training module (UI only)")),
          );
        },
      ),
    );
  }
}
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
}

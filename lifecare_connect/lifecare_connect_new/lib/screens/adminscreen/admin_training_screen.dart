import 'package:flutter/material.dart';

class AdminTrainingScreen extends StatefulWidget {
  const AdminTrainingScreen({super.key});

  @override
  State<AdminTrainingScreen> createState() => _AdminTrainingScreenState();
}

class _AdminTrainingScreenState extends State<AdminTrainingScreen> {
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
// This file defines the Admin Training screen for the app.
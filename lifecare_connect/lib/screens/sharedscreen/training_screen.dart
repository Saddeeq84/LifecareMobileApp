// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String? userRole;
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Video', 'PDF', 'Article'];

  Future<void> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userRole = userDoc.data()?['role'];
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole != 'chw' && userRole != 'patient') {
      return const Scaffold(
        body: Center(child: Text('Access restricted to CHWs and Patients.')),
      );
    }

    final query = FirebaseFirestore.instance
        .collection('training_materials')
        .where('targetRole', isEqualTo: userRole)
        .orderBy('uploadedAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Training Materials (${userRole!.toUpperCase()})'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search materials...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading materials.'));
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final category = data['category'] ?? 'Other';
                  final matchesSearch = title.contains(searchQuery);
                  final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching training materials found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>?;
                    final title = data?['title'] ?? 'No Title';
                    final description = data?['description'] ?? 'No Description';
                    final url = data?['url'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(description),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: url.isNotEmpty ? () => _launchUrl(url) : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../adminScreen/admin_upload_training_screen.dart';
import 'material_viewer_screen.dart'; // 📌 You must implement this

class TrainingEducationScreen extends StatefulWidget {
  const TrainingEducationScreen({super.key});

  @override
  State<TrainingEducationScreen> createState() => _TrainingEducationScreenState();
}

class _TrainingEducationScreenState extends State<TrainingEducationScreen> {
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _isAdmin = doc.exists && doc.data()?['role'] == 'admin';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Training & Education"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_materials')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading materials"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No training materials found."));
          }

          final materials = snapshot.data!.docs;

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final data = materials[index].data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Untitled';
              final description = data['description'] ?? '';
              final type = data['type'] ?? 'pdf';
              final url = data['url'] ?? '';

              return ListTile(
                leading: Icon(type == 'pdf' ? Icons.picture_as_pdf : Icons.video_library),
                title: Text(title),
                subtitle: Text(description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaterialViewerScreen(url: url, type: type),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminUploadTrainingScreen()),
                );
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.upload_file),
              tooltip: 'Upload Training Material',
            )
          : null,
    );
  }
}

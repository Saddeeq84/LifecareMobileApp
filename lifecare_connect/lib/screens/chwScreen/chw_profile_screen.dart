import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chw_edit_profile_screen.dart';
// Ensure that the following class exists in chw_edit_profile_screen.dart:
// class CHWEditProfileScreen extends StatelessWidget { ... }

class CHWProfileScreen extends StatelessWidget {
  const CHWProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading profile.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('❌ Profile not found.'));
          }

          final data = snapshot.data!.data()!;
          final fullName = data['fullName'] ?? 'Community Health Worker';
          final email = data['email'] ?? 'chw@example.com';
          final phone = data['phone'] ?? 'Not provided';
          final photoUrl = data['photoUrl'];

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Name: $fullName', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Email: $email', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CHWEditProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
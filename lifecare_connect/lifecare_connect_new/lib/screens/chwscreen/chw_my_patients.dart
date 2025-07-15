import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Update the import path below if the file exists elsewhere, for example:
import 'chw_patient_details_screen.dart';
// If the file does not exist, create 'chw_patient_detail_screen.dart' in the same directory.
import 'anc_checklist_screen.dart';

class CHWMyPatientsScreen extends StatefulWidget {
  const CHWMyPatientsScreen({super.key});

  @override
  State<CHWMyPatientsScreen> createState() => _CHWMyPatientsScreenState();
}

class _CHWMyPatientsScreenState extends State<CHWMyPatientsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('⚠️ Not authenticated')),
      );
    }

    final String chwId = currentUser!.uid;
    final Stream<QuerySnapshot> patientsStream = FirebaseFirestore.instance
        .collection('patients')
        .where('chwId', isEqualTo: chwId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export to PDF",
            onPressed: () {
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: patientsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('❌ Error loading patients.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("🩺 No matching patients."));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final patientId = doc.id;
                    final patientName = data['name'] ?? 'Unnamed';

                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.teal),
                      title: Text(patientName),
                      subtitle: Text(
                        "${data['age']} yrs • ${data['village'] ?? 'Unknown'} • ${data['status'] ?? 'Active'}",
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ANCChecklistScreen(
                              patientId: patientId,
                              patientName: patientName,
                            ),
                          ),
                        );
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CHWPatientDetailScreen(
                                    data: {
                                      ...data,
                                      'id': patientId,
                                    },
                                  ),
                                ),
                              );
                              break;
                            case 'edit':
                              _showEditDialog(context, doc.id, data);
                              break;
                            case 'delete':
                              _confirmDelete(context, doc.id);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'view', child: Text("View")),
                          const PopupMenuItem(value: 'edit', child: Text("Edit")),
                          const PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search by name...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          setState(() => searchQuery = value.trim());
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Patient"),
        content: const Text("Are you sure you want to delete this patient?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('patients').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Patient deleted")),
      );
    }
  }

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final phoneCtrl = TextEditingController(text: data['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Patient"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('patients').doc(docId).update({
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Patient updated")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

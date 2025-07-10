import 'package:flutter/material.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  final List<Map<String, String>> users = [
    {"name": "Dr. Amina Yusuf", "role": "Doctor", "email": "amina@lifecare.org"},
    {"name": "Kabiru Musa", "role": "CHW", "email": "kabiru@lifecare.org"},
    {"name": "Grace Danjuma", "role": "Patient", "email": "grace@lifecare.org"},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users
        .where((user) =>
            user["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user["email"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or email",
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
            child: filteredUsers.isEmpty
                ? const Center(child: Text("No matching users found."))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(user["name"]!),
                          subtitle: Text("${user["role"]} • ${user["email"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Edit ${user["name"]} (UI only)"),
                                ),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add user (UI only)")),
          );
        },
        tooltip: "Add New User",
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
// This screen allows the admin to manage users by searching, viewing, and editing user details.
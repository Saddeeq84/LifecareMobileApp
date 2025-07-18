// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  final Map<String, String> mockProfile = const {
    "name": "Dr. Amina Yusuf",
    "specialty": "Obstetrics & Gynecology",
    "email": "amina.yusuf@lifecare.org",
    "phone": "+234 802 123 4567",
    "department": "Maternal Health",
  };

  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out (UI only)")),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditDoctorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/doctor_avatar.png'),
            ),
            const SizedBox(height: 12),
            Text(
              mockProfile["name"]!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              mockProfile["specialty"]!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ProfileTile(label: "Email", value: mockProfile["email"]!),
            ProfileTile(label: "Phone", value: mockProfile["phone"]!),
            ProfileTile(label: "Department", value: mockProfile["department"]!),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String label;
  final String value;

  const ProfileTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: const Icon(Icons.info_outline, color: Colors.indigo),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({super.key});

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl =
      TextEditingController(text: "Dr. Amina Yusuf");
  final TextEditingController _phoneCtrl =
      TextEditingController(text: "+234 802 123 4567");
  final TextEditingController _deptCtrl =
      TextEditingController(text: "Maternal Health");

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated (UI only)")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deptCtrl,
                decoration: const InputDecoration(labelText: "Department"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

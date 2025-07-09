import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class CHWProfileScreen extends StatefulWidget {
  const CHWProfileScreen({super.key});

  @override
  State<CHWProfileScreen> createState() => _CHWProfileScreenState();
}

class _CHWProfileScreenState extends State<CHWProfileScreen> {
  bool notificationsEnabled = true;
  String language = 'English';
  String assignedFacility = 'PHC Tula Yiri, Ward 4';

  void _changeLanguage() {
    setState(() {
      language = language == 'English' ? 'Hausa' : 'English';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language set to $language')),
    );
  }

  void _editFacility() {
    final controller = TextEditingController(text: assignedFacility);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Assigned Facility'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter facility name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  assignedFacility = controller.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facility updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/chw1.png'),
                ),
                const SizedBox(height: 10),
                const Text('Amina Abdullahi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('CHW ID: LC-CHW-002'),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🏥 Assigned Facility Card
          Card(
            color: Colors.teal.shade50,
            child: ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.teal),
              title: const Text('Assigned Facility'),
              subtitle: Text(assignedFacility),
              trailing: const Icon(Icons.edit),
              onTap: _editFacility,
            ),
          ),

          const SizedBox(height: 20),

          // 📊 Performance Summary
          Card(
            color: Colors.green.shade50,
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.people, color: Colors.green),
                  title: Text('Patients Seen'),
                  trailing: Text('87'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.task_alt, color: Colors.green),
                  title: Text('Home Visits Made'),
                  trailing: Text('42'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.school, color: Colors.green),
                  title: Text('Sessions Attended'),
                  trailing: Text('6'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🌐 Language Toggle
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Language'),
            trailing: Text(language),
            onTap: _changeLanguage,
          ),

          const SizedBox(height: 20),

          // 📱 Personal Info
          const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile('Age', '35'),
          _infoTile('Gender', 'Female'),
          _infoTile('Phone', '+234 803 222 4567'),
          _infoTile('Location', 'Tula Yiri, Gombe'),

          const SizedBox(height: 30),

          // ⚙️ Settings
          const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            value: notificationsEnabled,
            title: const Text('Enable Notifications'),
            onChanged: (value) => setState(() => notificationsEnabled = value),
            secondary: const Icon(Icons.notifications_active_outlined),
          ),

          const SizedBox(height: 20),

          // 🚪 Logout
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated logout')),
              );
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
// This code defines a profile screen for Community Health Workers (CHWs) in a healthcare app.
// It includes features like editing the profile, viewing assigned facility, toggling language, and managing
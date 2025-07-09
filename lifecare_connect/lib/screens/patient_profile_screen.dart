import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/images/patient_avatar.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 14,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Change picture (UI only)")),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Maryam Ibrahim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text('Patient ID: LC-20451'),
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

        // 📅 Appointment Summary
        Card(
          color: Colors.green.shade50,
          child: ListTile(
            leading: const Icon(Icons.event_available, color: Colors.green),
            title: const Text('Next Appointment'),
            subtitle: const Text('July 15, 2025 • CHW Amina • ANC Follow-up'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment details (UI only)")),
              );
            },
          ),
        ),

        const SizedBox(height: 30),

        // 🔎 Personal Info
        const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _profileTile('Age', '29'),
        _profileTile('Gender', 'Female'),
        _profileTile('Phone', '+234 803 123 4567'),
        _profileTile('Location', 'Kabri Village, Gombe'),

        const SizedBox(height: 30),

        // ⚙️ Settings
        const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SwitchListTile(
          value: notificationsEnabled,
          title: const Text('Enable Notifications'),
          onChanged: (value) {
            setState(() {
              notificationsEnabled = value;
            });
          },
          secondary: const Icon(Icons.notifications_active_outlined),
        ),

        const SizedBox(height: 30),

        // 🚪 Logout Button
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulated logout')),
            );
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            });
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _profileTile(String title, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
// This code defines a profile screen for patients, allowing them to view and edit their personal information, manage notifications, and log out.
// It includes a profile picture, personal info section, appointment summary, and settings options.
import 'package:flutter/material.dart';

class CHWSettingsScreen extends StatelessWidget {
  const CHWSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Notification Settings'),
            leading: Icon(Icons.notifications),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            title: Text('Change Language'),
            leading: Icon(Icons.language),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            title: Text('Privacy & Security'),
            leading: Icon(Icons.lock),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            title: Text('About the App'),
            leading: Icon(Icons.info_outline),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

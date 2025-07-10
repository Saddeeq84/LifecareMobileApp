// lib/screens/dashboard_selector_screen.dart
import 'package:flutter/material.dart';

class DashboardSelectorScreen extends StatelessWidget {
  const DashboardSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboards = [
      {"title": "Patient", "route": "/patient_dashboard"},
      {"title": "CHW", "route": "/chw_dashboard"},
      {"title": "Doctor", "route": "/doctor_dashboard"},
      {"title": "Admin", "route": "/admin_dashboard"},
      {"title": "Facility", "route": "/facility_dashboard"}, // ✅ NEW
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Dashboard"),
        backgroundColor: Colors.teal.shade800,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: dashboards.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final dash = dashboards[index];
          return ListTile(
            title: Text(dash['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, dash['route']!);
            },
          );
        },
      ),
    );
  }
}

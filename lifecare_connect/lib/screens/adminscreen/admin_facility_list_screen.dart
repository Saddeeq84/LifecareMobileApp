import 'package:flutter/material.dart';
import '../sharedscreen/facility_list_widget.dart';

class AdminFacilityListScreen extends StatelessWidget {
  const AdminFacilityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Facilities")),
      body: FacilityListWidget(
        viewerRole: 'admin',
        onFacilityTap: (facility) {
          final name = facility['name'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing/Contacting $name')),
          );
        },
      ),
    );
  }
}

// screens/adminscreen/admin_facility_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sharedscreen/facility_list_widget.dart';

class AdminFacilityListScreen extends StatelessWidget {
  final String? facilityType;

  const AdminFacilityListScreen({super.key, this.facilityType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          facilityType != null ? '$facilityType Facilities' : 'All Facilities',
        ),
      ),
      body: FacilityListWidget(
        viewerRole: 'admin',
        facilityType: facilityType,
        onFacilityTap: (DocumentSnapshot facility) {
          final data = facility.data() as Map<String, dynamic>?;

          if (data == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facility data is unavailable')),
            );
            return;
          }

          final name = data['name'] ?? 'Unnamed Facility';

          // Handle tap on facility item
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening details for $name')),
          );

          // You can push to a detail screen here if needed.
          // Example: context.push('/admin/facility_details', extra: facility);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../sharedscreen/facility_list_widget.dart';

class CHWReferToFacilityScreen extends StatelessWidget {
  const CHWReferToFacilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Refer to Facility")),
      body: FacilityListWidget(
        viewerRole: 'chw',
        onFacilityTap: (facility) {
          final name = facility['name'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral initiated for $name')),
          );
        },
      ),
    );
  }
}

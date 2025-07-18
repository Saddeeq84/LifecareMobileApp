import 'package:flutter/material.dart';
import '../sharedscreen/facility_list_widget.dart';

class DoctorFacilityReferralScreen extends StatelessWidget {
  const DoctorFacilityReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Facility Referral & Messaging")),
      body: FacilityListWidget(
        viewerRole: 'doctor',
        onFacilityTap: (facility) {
          final name = facility['name'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Refer patient or message $name')),
          );
        },
      ),
    );
  }
}

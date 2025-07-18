import 'package:flutter/material.dart';
import '../sharedscreen/facility_list_widget.dart';

class PatientBookFacilityScreen extends StatelessWidget {
  const PatientBookFacilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Facility Service')),
      body: FacilityListWidget(
        viewerRole: 'patient',
        onFacilityTap: (facility) {
          final name = facility['name'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking appointment with $name')),
          );
        },
      ),
    );
  }
}

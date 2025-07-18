import 'package:flutter/material.dart';
import '../sharedscreen/chw_list_widget.dart';

class PatientBookCHWScreen extends StatelessWidget {
  const PatientBookCHWScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a CHW')),
      body: CHWListWidget(
        viewerRole: 'patient',
        onCHWTap: (chw) {
          final name = chw['fullName'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking CHW appointment with $name')),
          );
        },
      ),
    );
  }
}

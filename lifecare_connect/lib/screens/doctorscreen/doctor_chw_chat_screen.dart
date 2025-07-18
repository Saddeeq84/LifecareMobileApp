import 'package:flutter/material.dart';
import '../sharedscreen/chw_list_widget.dart';

class DoctorCHWChatScreen extends StatelessWidget {
  const DoctorCHWChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communicate with CHWs')),
      body: CHWListWidget(
        viewerRole: 'doctor',
        onCHWTap: (chw) {
          final name = chw['fullName'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening chat or video call with $name')),
          );
        },
      ),
    );
  }
}

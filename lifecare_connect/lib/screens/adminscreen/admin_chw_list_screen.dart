import 'package:flutter/material.dart';
import '../sharedscreen/chw_list_widget.dart';

class AdminCHWListScreen extends StatelessWidget {
  const AdminCHWListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CHW Performance View")),
      body: CHWListWidget(
        viewerRole: 'admin',
        onCHWTap: (chw) {
          final name = chw['fullName'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing performance for $name')),
          );
        },
      ),
    );
  }
}

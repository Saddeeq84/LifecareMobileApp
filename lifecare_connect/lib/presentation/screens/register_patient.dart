import 'package:flutter/material.dart';

class RegisterPatientScreen extends StatelessWidget {
  const RegisterPatientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Patient')),
      body: const Center(child: Text('Register Patient Screen')),
    );
  }
}

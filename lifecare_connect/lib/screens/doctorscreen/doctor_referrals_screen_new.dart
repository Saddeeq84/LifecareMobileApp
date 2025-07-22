import 'package:flutter/material.dart';
import '../sharedscreen/Shared_Referral_Widget.dart' as widget;
import '../sharedscreen/make_referral_form.dart';

class DoctorReferralsScreen extends StatelessWidget {
  const DoctorReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Referrals'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MakeReferralForm(role: 'doctor'),
                ),
              );
            },
          ),
        ],
      ),
      body: const widget.SharedReferralWidget(role: 'doctor'),
    );
  }
}

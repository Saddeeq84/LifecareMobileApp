import 'package:flutter/material.dart';
import '../sharedscreen/Shared_Referral_Widget.dart';

class FacilityReferralsScreen extends StatelessWidget {
  const FacilityReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Referrals'),
        backgroundColor: Colors.teal,
      ),
      body: const SharedReferralWidget(role: 'facility'),
    );
  }
}
import 'package:flutter/material.dart';
import '../sharedscreen/Shared_Referral_Widget.dart' as referral_widget;
import '../sharedscreen/make_referral_form.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MakeReferralForm(role: 'chw'),
                ),
              );
            },
          ),
        ],
      ),
      body: const referral_widget.SharedReferralWidget(role: 'chw'),
    );
  }
}

import 'package:flutter/material.dart';
import '../sharedscreen/Shared_Referral_Widget.dart' as widget;
import '../sharedscreen/make_referral_form.dart';

class CHWReferralScreen extends StatelessWidget {
  const CHWReferralScreen({super.key});

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
      body: const widget.SharedReferralWidget(role: 'chw'),
    );
  }
}

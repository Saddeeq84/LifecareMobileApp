import 'package:flutter/material.dart';
import '../sharedscreen/Shared_Referral_Widget.dart' as referral_widget;
import '../sharedscreen/make_referral_form.dart';
import '../../test_data/referral_test_data.dart';

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
          // Test data button (remove in production)
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'generate_test') {
                try {
                  await ReferralTestDataGenerator.generateTestReferrals();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test referrals generated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error generating test data: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_test',
                child: Row(
                  children: [
                    Icon(Icons.data_usage),
                    SizedBox(width: 8),
                    Text('Generate Test Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const referral_widget.SharedReferralWidget(role: 'chw'),
    );
  }
}

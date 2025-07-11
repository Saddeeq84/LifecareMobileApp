import 'package:flutter/material.dart';

class CHWTrainingAndEducationScreen extends StatelessWidget {
  const CHWTrainingAndEducationScreen({super.key});

  final List<Map<String, String>> topics = const [
    {
      'title': 'Antenatal Care (ANC)',
      'description': 'Learn how to support pregnant women during ANC visits.',
    },
    {
      'title': 'Postnatal Care (PNC)',
      'description': 'Post-delivery care for mothers and newborns.',
    },
    {
      'title': 'Emergency Obstetric Care',
      'description': 'Handling complications and danger signs in pregnancy.',
    },
    {
      'title': 'Labour & Delivery',
      'description': 'Care during childbirth, delivery monitoring and support.',
    },
    {
      'title': 'Breastfeeding Support',
      'description': 'Encouraging exclusive breastfeeding practices.',
    },
    {
      'title': 'Newborn Care',
      'description': 'Thermal protection, cord care, immunization and danger signs.',
    },
    {
      'title': 'General Health Topics',
      'description': 'Basic hygiene, nutrition, and child health information.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & Education'),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Text(
                topic['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(topic['description']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Later, navigate to detailed lesson or video
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening: ${topic['title']} (coming soon)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
// This screen provides training and educational resources for CHWs, covering key maternal and child health topics.
import 'package:flutter/material.dart';

class DailyHealthTipsScreen extends StatefulWidget {
  const DailyHealthTipsScreen({super.key});

  @override
  State<DailyHealthTipsScreen> createState() => _DailyHealthTipsScreenState();
}

class _DailyHealthTipsScreenState extends State<DailyHealthTipsScreen> {
  List<String> tips = [
    'Stay hydrated — drink at least 8 cups of water daily.',
    'Eat a balanced diet with fruits, vegetables, and grains.',
    'Get at least 30 minutes of physical activity daily.',
    'Wash hands before meals and after using the toilet.',
    'Attend all your antenatal/postnatal checkups.',
    'Sleep 7–8 hours for good mental and physical health.',
  ];

  Set<int> bookmarkedTips = {};
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final tipOfTheDay = tips[DateTime.now().day % tips.length];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🌞 Tip of the Day
        Card(
          color: Colors.green.shade100,
          child: ListTile(
            leading: Icon(Icons.wb_sunny_outlined, color: Colors.green.shade800),
            title: Text('Tip of the Day'),
            subtitle: Text(tipOfTheDay),
          ),
        ),
        const SizedBox(height: 20),

        // 🔔 Notification Toggle
        SwitchListTile(
          title: Text("Daily Tip Notifications"),
          subtitle: Text("Receive a daily notification for new health tips."),
          secondary: Icon(Icons.notifications_active_outlined, color: Colors.green),
          value: notificationsEnabled,
          onChanged: (value) {
            setState(() {
              notificationsEnabled = value;
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(value ? "Notifications enabled" : "Notifications disabled"),
              duration: Duration(seconds: 1),
            ));
          },
        ),
        const SizedBox(height: 16),

        // 📋 All Tips
        Text("All Tips", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        ...List.generate(tips.length, (index) {
          return Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Colors.green.shade700),
              title: Text('Tip #${index + 1}'),
              subtitle: Text(tips[index]),
              trailing: IconButton(
                icon: Icon(
                  bookmarkedTips.contains(index) ? Icons.bookmark : Icons.bookmark_outline,
                  color: bookmarkedTips.contains(index) ? Colors.green.shade800 : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (bookmarkedTips.contains(index)) {
                      bookmarkedTips.remove(index);
                    } else {
                      bookmarkedTips.add(index);
                    }
                  });
                },
                tooltip: 'Bookmark',
              ),
            ),
          );
        }),
      ],
    );
  }
}
// This code defines a screen for daily health tips, allowing users to view a tip of the day, toggle notifications, and bookmark tips.
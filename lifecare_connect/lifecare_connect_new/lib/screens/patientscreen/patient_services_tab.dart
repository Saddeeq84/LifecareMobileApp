import 'package:flutter/material.dart';
// Update the import path below to the correct relative location if needed
import '../facilityscreen/facility_list_screen.dart'; // Ensure this file exists and contains FacilityListScreen

class PatientServicesTab extends StatelessWidget {
  const PatientServicesTab({super.key});

  void _navigateToFacilityList(BuildContext context, String type, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FacilityListScreen(
          categoryType: type,
          categoryLabel: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'type': 'hospital', 'label': 'Hospitals', 'icon': Icons.local_hospital},
      {'type': 'laboratory', 'label': 'Laboratories', 'icon': Icons.science},
      {'type': 'pharmacy', 'label': 'Pharmacies', 'icon': Icons.local_pharmacy},
      {'type': 'scan_center', 'label': 'Scan Centers', 'icon': Icons.monitor_heart},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Services'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () => _navigateToFacilityList(
                context,
                category['type'] as String,
                category['label'] as String,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'] as IconData, size: 48, color: Colors.green.shade700),
                    const SizedBox(height: 12),
                    Text(
                      category['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// -------------------- End of Patient Services Tab --------------------
// This code provides a tab for patients to view and navigate to different healthcare service categories,
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'patient_facility_selection_screen.dart';
import '../../../facility/presentation/screens/patient_facility_booking_screen.dart';
// import 'patient_services_request_screen.dart'; // Removed: file does not exist

class PatientServiceRequestMainScreen extends StatefulWidget {
  const PatientServiceRequestMainScreen({super.key});

  @override
  State<PatientServiceRequestMainScreen> createState() => _PatientServiceRequestMainScreenState();
}

class _PatientServiceRequestMainScreenState extends State<PatientServiceRequestMainScreen> {
  String? selectedCategoryType;
  String? selectedCategoryLabel;
  String? selectedFacilityId;
  Map<String, dynamic>? selectedFacilityData;

  final categories = [
    {'type': 'hospital', 'label': 'Hospitals', 'icon': Icons.local_hospital},
    {'type': 'laboratory', 'label': 'Laboratories', 'icon': Icons.science},
    {'type': 'pharmacy', 'label': 'Pharmacies', 'icon': Icons.local_pharmacy},
    {'type': 'scan_center', 'label': 'Scan Centers', 'icon': Icons.monitor_heart},
    {'type': 'physiotherapy_center', 'label': 'Physiotherapy Centers', 'icon': Icons.accessibility},
    {'type': 'dental_clinic', 'label': 'Dental Clinics', 'icon': Icons.medical_information},
    {'type': 'eye_clinic', 'label': 'Eye Clinics', 'icon': Icons.visibility},
    {'type': 'mental_health_center', 'label': 'Mental Health Centers', 'icon': Icons.psychology},
  ];

  @override
  Widget build(BuildContext context) {
    // The PatientServicesRequestScreen widget and file do not exist. If you need to show a request screen, implement it here or use an alternative.

    if (selectedCategoryType != null && selectedCategoryLabel != null) {
      // Show the facility selection screen for the selected category
      return PatientFacilitySelectionScreen(
        key: ValueKey(selectedCategoryType),
        categoryType: selectedCategoryType!,
        categoryLabel: selectedCategoryLabel!,
        onFacilitySelected: (facilityId, facilityData) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientFacilityBookingScreen(
                facilityId: facilityId,
                facilityData: facilityData,
              ),
            ),
          );
        },
      );
    }

    // Show the category grid
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
              onTap: () {
                setState(() {
                  selectedCategoryType = category['type'] as String;
                  selectedCategoryLabel = category['label'] as String;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 48,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
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

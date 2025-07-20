import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityListWidget extends StatelessWidget {
  final String viewerRole;
  final Function(DocumentSnapshot facility) onFacilityTap;
  final String? facilityType; // New: optional facilityType for filtering

  const FacilityListWidget({
    super.key,
    required this.viewerRole,
    required this.onFacilityTap,
    this.facilityType,
  });

  @override
  Widget build(BuildContext context) {
    // Base Firestore reference
    Query facilityRef = FirebaseFirestore.instance.collection('facilities');

    // Apply filtering if facilityType is provided
    if (facilityType != null && facilityType!.isNotEmpty) {
      facilityRef = facilityRef.where('type', isEqualTo: facilityType);
    }

    // Default sorting
    facilityRef = facilityRef.orderBy('type');

    return StreamBuilder<QuerySnapshot>(
      stream: facilityRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No health facilities found."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final facility = docs[index];
            final data = facility.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Unknown Facility';
            final type = data['type'] ?? 'Unknown Type';
            final location = data['location'] ?? 'Unknown Location';
            final phone = data['phone'] ?? 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
                title: Text(name),
                subtitle: Text('$type\n$location\nPhone: $phone'),
                trailing: _buildTrailingIcon(context, facility),
                onTap: () => onFacilityTap(facility),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildTrailingIcon(BuildContext context, DocumentSnapshot facility) {
    final name = (facility.data() as Map<String, dynamic>)['name'] ?? 'Facility';

    switch (viewerRole) {
      case 'admin':
        return IconButton(
          icon: const Icon(Icons.message_outlined),
          tooltip: 'Message Facility',
          onPressed: () => onFacilityTap(facility),
        );
      case 'chw':
        return IconButton(
          icon: const Icon(Icons.forward_to_inbox),
          tooltip: 'Refer Patient',
          onPressed: () => onFacilityTap(facility),
        );
      case 'doctor':
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'refer') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Refer patient to $name')),
              );
            } else if (value == 'message') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message $name')),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'refer', child: Text('Refer Patient')),
            const PopupMenuItem(value: 'message', child: Text('Send Message')),
          ],
        );
      case 'patient':
        return IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: 'Book Service',
          onPressed: () => onFacilityTap(facility),
        );
      default:
        return null;
    }
  }
}

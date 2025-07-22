// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/health_records_service.dart';

class MyHealthRecordDetails extends StatelessWidget {
  final String recordId;
  final String recordType;

  const MyHealthRecordDetails({
    super.key,
    required this.recordId,
    required this.recordType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$recordType Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: HealthRecordsService.getHealthRecordDetails(recordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Error loading health record details'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final recordData = data['data'] as Map<String, dynamic>? ?? {};
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(data),
                const SizedBox(height: 16),
                if (recordType == 'ANC_VISIT') _buildANCDetails(recordData),
                if (recordType == 'SELF_REPORTED_VITALS') _buildVitalsDetails(recordData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp?)?.toDate();
    final providerName = data['providerName'] ?? 'Unknown';
    final providerType = data['providerType'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(),
            _buildInfoRow('Date:', date?.toLocal().toString().split('.')[0] ?? 'Unknown'),
            _buildInfoRow('Provider:', '$providerName ($providerType)'),
            _buildInfoRow('Record Type:', recordType.replaceAll('_', ' ')),
          ],
        ),
      ),
    );
  }

  Widget _buildANCDetails(Map<String, dynamic> data) {
    final nextVisitDate = (data['nextVisitDate'] as Timestamp?)?.toDate();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ANC Visit Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(),
            _buildInfoRow('Blood Pressure:', data['bloodPressure'] ?? 'Not recorded'),
            _buildInfoRow('Weight:', '${data['weight'] ?? 'Not recorded'} kg'),
            _buildInfoRow('Symptoms:', data['symptoms'] ?? 'None reported'),
            _buildInfoRow('Medications:', data['medications'] ?? 'None prescribed'),
            if (nextVisitDate != null)
              _buildInfoRow('Next Visit:', nextVisitDate.toLocal().toString().split(' ')[0]),
            if (data['notes'] != null && data['notes'].toString().isNotEmpty)
              _buildInfoRow('Notes:', data['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsDetails(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vital Signs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(),
            ...data.entries.map((entry) => 
              _buildInfoRow('${entry.key}:', entry.value?.toString() ?? 'Not recorded')
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
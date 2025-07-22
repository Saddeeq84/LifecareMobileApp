// Test data generator for appointments
// Run this once to populate test appointments

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentTestDataGenerator {
  static Future<void> generateTestAppointments() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    final chwId = currentUser.uid;
    final appointmentsRef = FirebaseFirestore.instance.collection('appointments');
    
    // Test appointments with different statuses
    final testAppointments = [
      {
        'staffId': chwId,
        'patientId': 'patient_001',
        'patientName': 'Sarah Johnson',
        'appointmentDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1, hours: 10))),
        'status': 'pending',
        'reason': 'Antenatal checkup',
        'bookedAt': Timestamp.now(),
      },
      {
        'staffId': chwId,
        'patientId': 'patient_002', 
        'patientName': 'Mary Wilson',
        'appointmentDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2, hours: 14))),
        'status': 'pending',
        'reason': 'Child vaccination',
        'bookedAt': Timestamp.now(),
      },
      {
        'staffId': chwId,
        'patientId': 'patient_003',
        'patientName': 'Jennifer Brown',
        'appointmentDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3, hours: 9))),
        'status': 'approved',
        'reason': 'Follow-up consultation',
        'bookedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'actionBy': chwId,
        'actionDate': Timestamp.now(),
      },
      {
        'staffId': chwId,
        'patientId': 'patient_004',
        'patientName': 'Lisa Davis',
        'appointmentDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'status': 'completed',
        'reason': 'Health screening',
        'bookedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'actionBy': chwId,
        'actionDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        'completedBy': chwId,
        'completedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'staffId': chwId,
        'patientId': 'patient_005',
        'patientName': 'Michelle Garcia',
        'appointmentDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'status': 'denied',
        'reason': 'Emergency consultation',
        'bookedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'actionBy': chwId,
        'actionDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
    ];
    
    // Add test appointments to Firestore
    for (final appointment in testAppointments) {
      await appointmentsRef.add(appointment);
    }
    
    print('✅ Test appointments generated successfully!');
  }
}

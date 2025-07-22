// Test data generator for referrals
// Run this once to populate test referrals

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferralTestDataGenerator {
  static Future<void> generateTestReferrals() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    final userId = currentUser.uid;
    final referralsRef = FirebaseFirestore.instance.collection('referrals');
    
    // Get current user's role to generate appropriate test referrals
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    final userRole = userDoc.data()?['role'] ?? 'chw';
    
    // Test referrals with different combinations based on user role
    final testReferrals = <Map<String, dynamic>>[];
    
    if (userRole == 'chw') {
      // CHW can send referrals to doctors and facilities
      testReferrals.addAll([
        {
          'patientId': 'patient_001',
          'patientName': 'Sarah Johnson',
          'fromUserId': userId,
          'fromRole': 'chw',
          'toUserId': 'doctor_001',
          'toRole': 'doctor',
          'reason': 'Needs specialist consultation for diabetes management',
          'urgency': 'high',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        },
        {
          'patientId': 'patient_002',
          'patientName': 'Mary Wilson',
          'fromUserId': userId,
          'fromRole': 'chw',
          'toUserId': 'facility_001',
          'toRole': 'facility',
          'reason': 'Requires X-ray examination for chest pain',
          'urgency': 'normal',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        },
        {
          'patientId': 'patient_003',
          'patientName': 'Jennifer Brown',
          'fromUserId': 'doctor_002',
          'fromRole': 'doctor',
          'toUserId': userId,
          'toRole': 'chw',
          'reason': 'Patient needs follow-up care and medication monitoring',
          'urgency': 'normal',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
      ]);
    } else if (userRole == 'doctor') {
      // Doctors can send referrals and receive them
      testReferrals.addAll([
        {
          'patientId': 'patient_004',
          'patientName': 'Lisa Davis',
          'fromUserId': userId,
          'fromRole': 'doctor',
          'toUserId': 'chw_001',
          'toRole': 'chw',
          'reason': 'Patient needs home care monitoring after surgery',
          'urgency': 'high',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        },
        {
          'patientId': 'patient_005',
          'patientName': 'Michelle Garcia',
          'fromUserId': userId,
          'fromRole': 'doctor',
          'toUserId': 'facility_002',
          'toRole': 'facility',
          'reason': 'Patient requires MRI scan for neurological assessment',
          'urgency': 'urgent',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
        },
        {
          'patientId': 'patient_006',
          'patientName': 'Robert Johnson',
          'fromUserId': 'chw_002',
          'fromRole': 'chw',
          'toUserId': userId,
          'toRole': 'doctor',
          'reason': 'Patient experiencing severe headaches, needs evaluation',
          'urgency': 'high',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
        },
      ]);
    } else if (userRole == 'facility') {
      // Facilities only receive referrals
      testReferrals.addAll([
        {
          'patientId': 'patient_007',
          'patientName': 'Anna Rodriguez',
          'fromUserId': 'doctor_003',
          'fromRole': 'doctor',
          'toUserId': userId,
          'toRole': 'facility',
          'reason': 'Patient needs blood work and complete health screening',
          'urgency': 'normal',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
        },
        {
          'patientId': 'patient_008',
          'patientName': 'James Wilson',
          'fromUserId': 'chw_003',
          'fromRole': 'chw',
          'toUserId': userId,
          'toRole': 'facility',
          'reason': 'Emergency referral for severe abdominal pain',
          'urgency': 'urgent',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 45))),
        },
      ]);
    } else if (userRole == 'patient') {
      // Patients have referrals created for them (approved ones they can see)
      testReferrals.addAll([
        {
          'patientId': userId,
          'patientName': 'Your Referral',
          'fromUserId': 'doctor_004',
          'fromRole': 'doctor',
          'toUserId': 'facility_003',
          'toRole': 'facility',
          'reason': 'Scheduled for routine laboratory tests as recommended',
          'urgency': 'normal',
          'status': 'approved',
          'actionBy': 'facility_003',
          'actionDate': Timestamp.now(),
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          'patientAcknowledged': false,
        },
      ]);
    } else if (userRole == 'admin') {
      // Admin sees sample referrals from all roles
      testReferrals.addAll([
        {
          'patientId': 'patient_009',
          'patientName': 'Sample Patient 1',
          'fromUserId': 'doctor_005',
          'fromRole': 'doctor',
          'toUserId': 'chw_004',
          'toRole': 'chw',
          'reason': 'Post-treatment follow-up required',
          'urgency': 'normal',
          'status': 'approved',
          'actionBy': 'chw_004',
          'actionDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        },
        {
          'patientId': 'patient_010',
          'patientName': 'Sample Patient 2',
          'fromUserId': 'chw_005',
          'fromRole': 'chw',
          'toUserId': 'facility_004',
          'toRole': 'facility',
          'reason': 'Requires diagnostic imaging',
          'urgency': 'high',
          'status': 'rejected',
          'actionBy': 'facility_004',
          'actionDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
          'actionReason': 'Equipment currently unavailable, please try alternative facility',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
      ]);
    }
    
    // Add test referrals to Firestore
    for (final referral in testReferrals) {
      await referralsRef.add(referral);
    }
    
    print('✅ Test referrals generated successfully for $userRole!');
    print('Generated ${testReferrals.length} test referrals');
  }
}

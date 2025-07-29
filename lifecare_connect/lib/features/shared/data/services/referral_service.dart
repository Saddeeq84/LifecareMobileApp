// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/referral.dart';
import 'message_service.dart';

class ReferralService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new referral
  static Future<String> createReferral({
    required String patientId,
    required String patientName,
    required String fromProviderId,
    required String fromProviderName,
    required String fromProviderType,
    required String toProviderId,
    required String toProviderName,
    required String toProviderType,
    required String reason,
    required String urgency,
    String? notes,
    String? facilityId,
    String? facilityName,
    Map<String, dynamic>? medicalHistory,
    List<String>? attachments,
  }) async {
    try {
      final referralData = {
        'patientId': patientId,
        'patientName': patientName,
        'fromProviderId': fromProviderId,
        'fromProviderName': fromProviderName,
        'fromProviderType': fromProviderType,
        'toProviderId': toProviderId,
        'toProviderName': toProviderName,
        'toProviderType': toProviderType,
        'reason': reason,
        'urgency': urgency,
        'status': 'pending',
        'notes': notes,
        'facilityId': facilityId,
        'facilityName': facilityName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'medicalHistory': medicalHistory,
        'attachments': attachments,
      };

      final docRef = await _firestore
          .collection('referrals')
          .add(referralData);

      // Send notification to the receiving provider about new referral
      try {
        if (fromProviderType.toLowerCase() == 'chw' && toProviderType.toLowerCase() == 'doctor') {
          await MessageService.notifyDoctorOfChwReferral(
            referralId: docRef.id,
            chwId: fromProviderId,
            doctorId: toProviderId,
            patientName: patientName,
            reason: reason,
            urgency: urgency,
          );
          print('✅ CHW referral notification sent to doctor');
        } else if (fromProviderType.toLowerCase() == 'doctor' && toProviderType.toLowerCase() == 'doctor') {
          await MessageService.notifyDoctorOfReferral(
            referralId: docRef.id,
            referringDoctorId: fromProviderId,
            referredDoctorId: toProviderId,
            patientName: patientName,
            reason: reason,
            specialty: toProviderType,
          );
          print('✅ Doctor-to-doctor referral notification sent');
        }
      } catch (notificationError) {
        print('⚠️ Failed to send referral notification: $notificationError');
        // Don't fail the referral creation if notification fails
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create referral: $e');
    }
  }

  /// Update referral status (approve, reject, complete)
  static Future<void> updateReferralStatus({
    required String referralId,
    required String status,
    required String actionBy,
    String? actionNotes,
  }) async {
    try {
      final updateData = {
        'status': status,
        'actionBy': actionBy,
        'actionDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (actionNotes != null) {
        updateData['actionNotes'] = actionNotes;
      }

      await _firestore
          .collection('referrals')
          .doc(referralId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update referral status: $e');
    }
  }

  /// Get referrals for a specific CHW (sent by them)
  static Stream<QuerySnapshot> getCHWReferrals({
    required String chwId,
    String? status,
    List<String>? statusList,
  }) {
    Query query = _firestore
        .collection('referrals')
        .where('fromProviderId', isEqualTo: chwId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else if (statusList != null && statusList.isNotEmpty) {
      query = query.where('status', whereIn: statusList);
    }

    return query.snapshots();
  }

  /// Get referrals for a specific doctor (received by them)
  static Stream<QuerySnapshot> getDoctorReferrals({
    required String doctorId,
    String? status,
    List<String>? statusList,
  }) {
    Query query = _firestore
        .collection('referrals')
        .where('toProviderId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else if (statusList != null && statusList.isNotEmpty) {
      query = query.where('status', whereIn: statusList);
    }

    return query.snapshots();
  }

  /// Get referrals for a specific patient (view only)
  static Stream<QuerySnapshot> getPatientReferrals({
    required String patientId,
    String? status,
    List<String>? statusList,
  }) {
    Query query = _firestore
        .collection('referrals')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else if (statusList != null && statusList.isNotEmpty) {
      query = query.where('status', whereIn: statusList);
    }

    return query.snapshots();
  }

  /// Get referrals for a specific facility
  static Stream<QuerySnapshot> getFacilityReferrals({
    required String facilityId,
    String? status,
    List<String>? statusList,
  }) {
    Query query = _firestore
        .collection('referrals')
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else if (statusList != null && statusList.isNotEmpty) {
      query = query.where('status', whereIn: statusList);
    }

    return query.snapshots();
  }

  /// Get all referrals (admin view)
  static Stream<QuerySnapshot> getAllReferrals({
    String? status,
    List<String>? statusList,
    String? urgency,
  }) {
    Query query = _firestore
        .collection('referrals')
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else if (statusList != null && statusList.isNotEmpty) {
      query = query.where('status', whereIn: statusList);
    }

    if (urgency != null) {
      query = query.where('urgency', isEqualTo: urgency);
    }

    return query.snapshots();
  }

  /// Get referral by ID
  static Future<Referral?> getReferralById(String referralId) async {
    try {
      final doc = await _firestore
          .collection('referrals')
          .doc(referralId)
          .get();

      if (doc.exists) {
        return Referral.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get referral: $e');
    }
  }

  /// Update referral notes
  static Future<void> updateReferralNotes({
    required String referralId,
    required String notes,
  }) async {
    try {
      await _firestore
          .collection('referrals')
          .doc(referralId)
          .update({
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update referral notes: $e');
    }
  }

  /// Search referrals by patient name
  static Stream<QuerySnapshot> searchReferralsByPatient({
    required String searchTerm,
    String? fromProviderId,
    String? toProviderId,
  }) {
    Query query = _firestore
        .collection('referrals')
        .where('patientName', isGreaterThanOrEqualTo: searchTerm)
        .where('patientName', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .orderBy('patientName')
        .orderBy('createdAt', descending: true);

    if (fromProviderId != null) {
      query = query.where('fromProviderId', isEqualTo: fromProviderId);
    }

    if (toProviderId != null) {
      query = query.where('toProviderId', isEqualTo: toProviderId);
    }

    return query.snapshots();
  }

  /// Get referral statistics for a provider
  static Future<Map<String, int>> getReferralStats({
    required String providerId,
    required String providerType,
  }) async {
    try {
      final Query query;
      if (providerType == 'CHW') {
        query = _firestore
            .collection('referrals')
            .where('fromProviderId', isEqualTo: providerId);
      } else {
        query = _firestore
            .collection('referrals')
            .where('toProviderId', isEqualTo: providerId);
      }

      final snapshot = await query.get();
      final referrals = snapshot.docs;

      int pending = 0;
      int approved = 0;
      int rejected = 0;
      int completed = 0;

      for (final doc in referrals) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
          case 'completed':
            completed++;
            break;
        }
      }

      return {
        'total': referrals.length,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'completed': completed,
      };
    } catch (e) {
      throw Exception('Failed to get referral statistics: $e');
    }
  }
}

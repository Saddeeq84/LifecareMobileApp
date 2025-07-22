import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecordsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save ANC checklist data to patient's health records
  static Future<String> saveANCRecord({
    required String patientUid,
    required String chwUid,
    required String chwName,
    required Map<String, dynamic> ancData,
  }) async {
    try {
      final recordData = {
        'type': 'ANC_VISIT',
        'patientUid': patientUid,
        'providerId': chwUid,
        'providerName': chwName,
        'providerType': 'CHW',
        'date': FieldValue.serverTimestamp(),
        'data': ancData,
        'accessibleBy': ['patient', 'chw', 'doctor'], // Who can access this record
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('health_records')
          .add(recordData);

      // Also save reference in patient's subcollection for easier querying
      await _firestore
          .collection('patients')
          .doc(patientUid)
          .collection('health_records')
          .doc(docRef.id)
          .set({
        'recordRef': docRef.id,
        'type': 'ANC_VISIT',
        'date': FieldValue.serverTimestamp(),
        'providerId': chwUid,
        'providerName': chwName,
        'providerType': 'CHW',
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save ANC record: $e');
    }
  }

  /// Update existing ANC record
  static Future<void> updateANCRecord({
    required String recordId,
    required Map<String, dynamic> ancData,
  }) async {
    try {
      await _firestore
          .collection('health_records')
          .doc(recordId)
          .update({
        'data': ancData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ANC record: $e');
    }
  }

  /// Get health records for a patient (accessible by patient, CHW, doctor)
  static Stream<QuerySnapshot> getPatientHealthRecords(String patientUid) {
    return _firestore
        .collection('health_records')
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Get specific health record details
  static Future<DocumentSnapshot> getHealthRecordDetails(String recordId) {
    return _firestore
        .collection('health_records')
        .doc(recordId)
        .get();
  }

  /// Get patients managed by a CHW
  static Stream<QuerySnapshot> getPatientsByCHW(String chwUid) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('createdBy', isEqualTo: chwUid)
        .snapshots();
  }

  /// Check if current user can access a health record
  static Future<bool> canAccessRecord(String recordId, String userRole) async {
    try {
      final doc = await _firestore
          .collection('health_records')
          .doc(recordId)
          .get();
      
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>;
      final accessibleBy = List<String>.from(data['accessibleBy'] ?? []);
      
      return accessibleBy.contains(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Save patient self-reported vitals
  static Future<String> saveSelfReportedVitals({
    required String patientUid,
    required Map<String, dynamic> vitalsData,
  }) async {
    try {
      final recordData = {
        'type': 'SELF_REPORTED_VITALS',
        'patientUid': patientUid,
        'providerId': patientUid,
        'providerName': 'Self-Reported',
        'providerType': 'PATIENT',
        'date': FieldValue.serverTimestamp(),
        'data': vitalsData,
        'accessibleBy': ['patient', 'chw', 'doctor'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('health_records')
          .add(recordData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save vitals: $e');
    }
  }
}

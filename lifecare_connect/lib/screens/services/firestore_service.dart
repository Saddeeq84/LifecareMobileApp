// File: lib/services/firestore_service.dart

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add new patient data
  Future<void> addPatient(Map<String, dynamic> data) async {
    await _db.collection('patients').add(data);
  }

  /// Get list of patients added by a specific CHW
  Stream<QuerySnapshot> getPatientsByCHW(String chwId) {
    return _db
        .collection('patients')
        .where('chwId', isEqualTo: chwId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get a specific patient by document ID
  Future<DocumentSnapshot> getPatientById(String patientId) async {
    return await _db.collection('patients').doc(patientId).get();
  }

  /// Get all patients (e.g., for admin dashboard)
  Stream<QuerySnapshot> getAllPatients() {
    return _db
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update patient information
  Future<void> updatePatient(String patientId, Map<String, dynamic> updates) async {
    await _db.collection('patients').doc(patientId).update(updates);
  }

  /// Delete a patient record
  Future<void> deletePatient(String patientId) async {
    await _db.collection('patients').doc(patientId).delete();
  }

  /// Save a new chat message
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    await _db.collection('messages').add(messageData);
  }

  /// Get count of unread messages for a CHW
  Stream<int> getUnreadMessages(String chwId) {
    return _db
        .collection('messages')
        .where('receiverId', isEqualTo: chwId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(String messageId) async {
    await _db.collection('messages').doc(messageId).update({'read': true});
  }

  /// Schedule a new appointment
  Future<void> scheduleAppointment(Map<String, dynamic> appointmentData) async {
    await _db.collection('appointments').add(appointmentData);
  }

  /// Add a new referral record
  Future<void> addReferral(Map<String, dynamic> referralData) async {
    await _db.collection('referrals').add(referralData);
  }

  /// Fetch referrals created by a specific CHW
  Stream<QuerySnapshot> getReferralsByCHW(String chwId) {
    return _db
        .collection('referrals')
        .where('chwId', isEqualTo: chwId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Search patients by name (case-insensitive prefix match, client-side filtering recommended)
  Stream<QuerySnapshot> searchPatientsByName(String chwId, String namePrefix) {
    return _db
        .collection('patients')
        .where('chwId', isEqualTo: chwId)
        .orderBy('name')
        .startAt([namePrefix])
        .endAt([namePrefix + '\uf8ff'])
        .snapshots();
  }
}

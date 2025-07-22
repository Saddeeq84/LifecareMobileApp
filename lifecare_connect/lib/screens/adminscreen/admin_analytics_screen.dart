// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool isLoading = true;
  Map<String, int> userStats = {};
  Map<String, int> activityStats = {};
  Map<String, dynamic> healthcareStats = {};
  List<Map<String, dynamic>> recentActivities = [];
  
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);
    
    try {
      await Future.wait([
        _loadUserStatistics(),
        _loadActivityStatistics(),
        _loadHealthcareStatistics(),
        _loadRecentActivities(),
      ]);
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserStatistics() async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);

      // Total users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      // New users this month
      final newUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth))
          .get();

      // Users by role
      final adminCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'admin').length;
      final doctorCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'doctor').length;
      final chwCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'chw').length;
      final patientCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'patient').length;
      final facilityCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'facility').length;

      setState(() {
        userStats = {
          'total': usersSnapshot.docs.length,
          'newThisMonth': newUsersSnapshot.docs.length,
          'admins': adminCount,
          'doctors': doctorCount,
          'chws': chwCount,
          'patients': patientCount,
          'facilities': facilityCount,
        };
      });
    } catch (e) {
      print('Error loading user statistics: $e');
    }
  }

  Future<void> _loadActivityStatistics() async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);

      // Appointments
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .get();

      final monthlyAppointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth))
          .get();

      // Consultations
      final consultationsSnapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .get();

      final monthlyConsultations = await FirebaseFirestore.instance
          .collection('consultations')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth))
          .get();

      // Referrals
      final referralsSnapshot = await FirebaseFirestore.instance
          .collection('referrals')
          .get();

      final monthlyReferrals = await FirebaseFirestore.instance
          .collection('referrals')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth))
          .get();

      setState(() {
        activityStats = {
          'totalAppointments': appointmentsSnapshot.docs.length,
          'monthlyAppointments': monthlyAppointments.docs.length,
          'totalConsultations': consultationsSnapshot.docs.length,
          'monthlyConsultations': monthlyConsultations.docs.length,
          'totalReferrals': referralsSnapshot.docs.length,
          'monthlyReferrals': monthlyReferrals.docs.length,
        };
      });
    } catch (e) {
      print('Error loading activity statistics: $e');
    }
  }

  Future<void> _loadHealthcareStatistics() async {
    try {
      // Health Facilities
      final facilitiesSnapshot = await FirebaseFirestore.instance
          .collection('healthFacilities')
          .get();

      // Training Sessions
      final trainingsSnapshot = await FirebaseFirestore.instance
          .collection('trainings')
          .get();

      setState(() {
        healthcareStats = {
          'totalFacilities': facilitiesSnapshot.docs.length,
          'totalTrainings': trainingsSnapshot.docs.length,
        };
      });
    } catch (e) {
      print('Error loading healthcare statistics: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      final activities = <Map<String, dynamic>>[];

      // Recent appointments
      final recentAppointments = await FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      for (var doc in recentAppointments.docs) {
        activities.add({
          'type': 'Appointment',
          'description': 'New appointment scheduled',
          'timestamp': doc.data()['created_at'],
          'icon': Icons.calendar_today,
        });
      }

      // Recent consultations
      final recentConsultations = await FirebaseFirestore.instance
          .collection('consultations')
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      for (var doc in recentConsultations.docs) {
        activities.add({
          'type': 'Consultation',
          'description': 'New consultation completed',
          'timestamp': doc.data()['created_at'],
          'icon': Icons.medical_services,
        });
      }

      // Sort by timestamp
      activities.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      setState(() {
        recentActivities = activities.take(10).toList();
      });
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserStatistics(),
                    const SizedBox(height: 24),
                    _buildActivityStatistics(),
                    const SizedBox(height: 24),
                    _buildHealthcareStatistics(),
                    const SizedBox(height: 24),
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'User Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Total Users', userStats['total'] ?? 0, Icons.group, Colors.blue),
                _buildStatCard('New This Month', userStats['newThisMonth'] ?? 0, Icons.person_add, Colors.green),
                _buildStatCard('Doctors', userStats['doctors'] ?? 0, Icons.medical_services, Colors.red),
                _buildStatCard('CHWs', userStats['chws'] ?? 0, Icons.health_and_safety, Colors.orange),
                _buildStatCard('Patients', userStats['patients'] ?? 0, Icons.personal_injury, Colors.purple),
                _buildStatCard('Facilities', userStats['facilities'] ?? 0, Icons.local_hospital, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Activity Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Total Appointments', activityStats['totalAppointments'] ?? 0, Icons.calendar_today, Colors.blue),
                _buildStatCard('Monthly Appointments', activityStats['monthlyAppointments'] ?? 0, Icons.today, Colors.green),
                _buildStatCard('Total Consultations', activityStats['totalConsultations'] ?? 0, Icons.medical_services, Colors.red),
                _buildStatCard('Monthly Consultations', activityStats['monthlyConsultations'] ?? 0, Icons.healing, Colors.orange),
                _buildStatCard('Total Referrals', activityStats['totalReferrals'] ?? 0, Icons.compare_arrows, Colors.purple),
                _buildStatCard('Monthly Referrals', activityStats['monthlyReferrals'] ?? 0, Icons.arrow_forward, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthcareStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Healthcare System',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Health Facilities', healthcareStats['totalFacilities'] ?? 0, Icons.local_hospital, Colors.blue),
                _buildStatCard('Training Programs', healthcareStats['totalTrainings'] ?? 0, Icons.school, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            recentActivities.isEmpty
                ? const Center(
                    child: Text(
                      'No recent activities',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentActivities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = recentActivities[index];
                      final timestamp = activity['timestamp'] as Timestamp?;
                      final timeString = timestamp != null
                          ? DateFormat('MMM dd, yyyy - HH:mm').format(timestamp.toDate())
                          : 'Unknown time';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withValues(alpha: 0.1),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: Colors.teal,
                          ),
                        ),
                        title: Text(activity['type'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity['description'] ?? 'No description'),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: avoid_print, deprecated_member_use

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
    }
    
    setState(() => isLoading = false);
  }

  Future<void> _loadUserStatistics() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    Map<String, int> stats = {
      'total': users.docs.length,
      'admin': 0,
      'doctor': 0,
      'chw': 0,
      'patient': 0,
      'facility': 0,
      'active_today': 0,
      'active_week': 0,
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    for (var doc in users.docs) {
      final data = doc.data();
      final role = data['role'] ?? 'patient';
      stats[role] = (stats[role] ?? 0) + 1;

      // Check last login for activity
      if (data['lastLogin'] != null) {
        final lastLogin = (data['lastLogin'] as Timestamp).toDate();
        if (lastLogin.isAfter(today)) {
          stats['active_today'] = stats['active_today']! + 1;
        }
        if (lastLogin.isAfter(weekAgo)) {
          stats['active_week'] = stats['active_week']! + 1;
        }
      }
    }

    userStats = stats;
  }

  Future<void> _loadActivityStatistics() async {
    final appointments = await FirebaseFirestore.instance.collection('appointments').get();
    final consultations = await FirebaseFirestore.instance.collection('consultations').get();
    final referrals = await FirebaseFirestore.instance.collection('referrals').get();
    final messages = await FirebaseFirestore.instance.collection('messages').get();

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    Map<String, int> stats = {
      'total_appointments': appointments.docs.length,
      'total_consultations': consultations.docs.length,
      'total_referrals': referrals.docs.length,
      'total_messages': messages.docs.length,
      'appointments_this_month': 0,
      'consultations_this_month': 0,
      'referrals_this_month': 0,
      'completed_appointments': 0,
      'pending_referrals': 0,
    };

    // Count monthly activities
    for (var doc in appointments.docs) {
      final data = doc.data();
      if (data['createdAt'] != null) {
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.isAfter(thisMonth)) {
          stats['appointments_this_month'] = stats['appointments_this_month']! + 1;
        }
      }
      if (data['status'] == 'completed') {
        stats['completed_appointments'] = stats['completed_appointments']! + 1;
      }
    }

    for (var doc in consultations.docs) {
      final data = doc.data();
      if (data['createdAt'] != null) {
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.isAfter(thisMonth)) {
          stats['consultations_this_month'] = stats['consultations_this_month']! + 1;
        }
      }
    }

    for (var doc in referrals.docs) {
      final data = doc.data();
      if (data['createdAt'] != null) {
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.isAfter(thisMonth)) {
          stats['referrals_this_month'] = stats['referrals_this_month']! + 1;
        }
      }
      if (data['status'] == 'pending') {
        stats['pending_referrals'] = stats['pending_referrals']! + 1;
      }
    }

    activityStats = stats;
  }

  Future<void> _loadHealthcareStatistics() async {
    final facilities = await FirebaseFirestore.instance.collection('healthFacilities').get();
    final trainings = await FirebaseFirestore.instance.collection('trainings').get();
    
    Map<String, dynamic> stats = {
      'total_facilities': facilities.docs.length,
      'approved_facilities': 0,
      'pending_facilities': 0,
      'total_trainings': trainings.docs.length,
      'active_trainings': 0,
      'facility_types': <String, int>{},
    };

    for (var doc in facilities.docs) {
      final data = doc.data();
      final status = data['status'] ?? 'pending';
      if (status == 'approved') {
        stats['approved_facilities'] = stats['approved_facilities'] + 1;
      } else {
        stats['pending_facilities'] = stats['pending_facilities'] + 1;
      }

      final type = data['type'] ?? 'Unknown';
      stats['facility_types'][type] = (stats['facility_types'][type] ?? 0) + 1;
    }

    for (var doc in trainings.docs) {
      final data = doc.data();
      if (data['isActive'] == true) {
        stats['active_trainings'] = stats['active_trainings'] + 1;
      }
    }

    healthcareStats = stats;
  }

  Future<void> _loadRecentActivities() async {
    final activities = <Map<String, dynamic>>[];
    
    // Get recent appointments
    final appointments = await FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    
    for (var doc in appointments.docs) {
      final data = doc.data();
      activities.add({
        'type': 'Appointment',
        'description': 'New appointment scheduled',
        'time': data['createdAt'],
        'icon': Icons.calendar_today,
        'color': Colors.blue,
      });
    }

    // Get recent referrals
    final referrals = await FirebaseFirestore.instance
        .collection('referrals')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    
    for (var doc in referrals.docs) {
      final data = doc.data();
      activities.add({
        'type': 'Referral',
        'description': 'New referral created',
        'time': data['createdAt'],
        'icon': Icons.transfer_within_a_station,
        'color': Colors.orange,
      });
    }

    // Sort by time and take top 10
    activities.sort((a, b) {
      final aTime = a['time'] as Timestamp?;
      final bTime = b['time'] as Timestamp?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    recentActivities = activities.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
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
            const Text(
              'User Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Total Users', userStats['total'] ?? 0, Icons.people, Colors.blue),
                _buildStatCard('Patients', userStats['patient'] ?? 0, Icons.person, Colors.green),
                _buildStatCard('Doctors', userStats['doctor'] ?? 0, Icons.medical_services, Colors.red),
                _buildStatCard('CHWs', userStats['chw'] ?? 0, Icons.health_and_safety, Colors.orange),
                _buildStatCard('Facilities', userStats['facility'] ?? 0, Icons.local_hospital, Colors.purple),
                _buildStatCard('Active Today', userStats['active_today'] ?? 0, Icons.trending_up, Colors.teal),
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
            const Text(
              'Activity Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Total Appointments', activityStats['total_appointments'] ?? 0, Icons.calendar_today, Colors.indigo),
                _buildStatCard('This Month', activityStats['appointments_this_month'] ?? 0, Icons.event, Colors.blue),
                _buildStatCard('Total Consultations', activityStats['total_consultations'] ?? 0, Icons.video_call, Colors.green),
                _buildStatCard('This Month', activityStats['consultations_this_month'] ?? 0, Icons.call, Colors.teal),
                _buildStatCard('Total Referrals', activityStats['total_referrals'] ?? 0, Icons.transfer_within_a_station, Colors.orange),
                _buildStatCard('Pending', activityStats['pending_referrals'] ?? 0, Icons.pending, Colors.red),
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
            const Text(
              'Healthcare System',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Health Facilities', healthcareStats['total_facilities'] ?? 0, Icons.local_hospital, Colors.purple),
                _buildStatCard('Approved', healthcareStats['approved_facilities'] ?? 0, Icons.verified, Colors.green),
                _buildStatCard('Pending Approval', healthcareStats['pending_facilities'] ?? 0, Icons.pending_actions, Colors.orange),
                _buildStatCard('Training Materials', healthcareStats['total_trainings'] ?? 0, Icons.school, Colors.blue),
              ],
            ),
            if (healthcareStats['facility_types'] != null && healthcareStats['facility_types'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Facility Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...healthcareStats['facility_types'].entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Chip(
                        label: Text(entry.value.toString()),
                        backgroundColor: Colors.teal.shade100,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentActivities.isEmpty)
              const Center(
                child: Text('No recent activities'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = recentActivities[index];
                  final time = activity['time'] as Timestamp?;
                  final timeStr = time != null 
                      ? DateFormat('MMM dd, HH:mm').format(time.toDate())
                      : 'Unknown time';
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: activity['color'].withOpacity(0.1),
                      child: Icon(
                        activity['icon'],
                        color: activity['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(activity['type']),
                    subtitle: Text(activity['description']),
                    trailing: Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// This file defines the Admin Reports screen for the app.
// It includes a summary of key metrics and a placeholder for detailed reports.
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacilitySettingsScreen extends StatefulWidget {
  const FacilitySettingsScreen({super.key});

  @override
  State<FacilitySettingsScreen> createState() => _FacilitySettingsScreenState();
}

class _FacilitySettingsScreenState extends State<FacilitySettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _newRequestAlerts = true;
  bool _appointmentReminders = true;
  bool _autoApproval = false;
  bool _isLoading = true;
  bool _isSaving = false;
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final settings = data['settings'] as Map<String, dynamic>? ?? {};
        
        setState(() {
          _notificationsEnabled = settings['notificationsEnabled'] ?? true;
          _emailNotifications = settings['emailNotifications'] ?? true;
          _smsNotifications = settings['smsNotifications'] ?? false;
          _newRequestAlerts = settings['newRequestAlerts'] ?? true;
          _appointmentReminders = settings['appointmentReminders'] ?? true;
          _autoApproval = settings['autoApproval'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final settings = {
        'notificationsEnabled': _notificationsEnabled,
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'newRequestAlerts': _newRequestAlerts,
        'appointmentReminders': _appointmentReminders,
        'autoApproval': _autoApproval,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'settings': settings});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Settings saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Settings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          _isSaving
            ? Container(
                padding: const EdgeInsets.all(14),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : TextButton(
                onPressed: _saveSettings,
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications),
            const SizedBox(height: 16),
            
            _buildSwitchTile(
              'Enable Notifications',
              'Receive notifications for new requests and updates',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            
            if (_notificationsEnabled) ...[
              _buildSwitchTile(
                'Email Notifications',
                'Receive notifications via email',
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
              ),
              
              _buildSwitchTile(
                'SMS Notifications',
                'Receive notifications via SMS',
                _smsNotifications,
                (value) => setState(() => _smsNotifications = value),
              ),
              
              _buildSwitchTile(
                'New Request Alerts',
                'Get immediate alerts for new service requests',
                _newRequestAlerts,
                (value) => setState(() => _newRequestAlerts = value),
              ),
              
              _buildSwitchTile(
                'Appointment Reminders',
                'Receive reminders for upcoming appointments',
                _appointmentReminders,
                (value) => setState(() => _appointmentReminders = value),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Service Management Section
            _buildSectionHeader('Service Management', Icons.settings),
            const SizedBox(height: 16),
            
            _buildSwitchTile(
              'Auto-Approval (Low Priority)',
              'Automatically approve routine service requests',
              _autoApproval,
              (value) => setState(() => _autoApproval = value),
            ),
            
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.teal),
              title: const Text('Operating Hours'),
              subtitle: const Text('Set your facility operating hours'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showOperatingHoursDialog,
            ),
            
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.teal),
              title: const Text('Service Categories'),
              subtitle: const Text('Manage available service categories'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showServiceCategoriesDialog,
            ),
            
            const SizedBox(height: 32),
            
            // Account Security Section
            _buildSectionHeader('Account Security', Icons.security),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.teal),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showChangePasswordDialog,
            ),
            
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.teal),
              title: const Text('Privacy Settings'),
              subtitle: const Text('Manage data privacy preferences'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showPrivacyDialog,
            ),
            
            const SizedBox(height: 32),
            
            // Support Section
            _buildSectionHeader('Support & Information', Icons.help),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.teal),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with using the platform'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showHelpDialog,
            ),
            
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.teal),
              title: const Text('About'),
              subtitle: const Text('App version and legal information'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showAboutDialog,
            ),
            
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.teal),
              title: const Text('Send Feedback'),
              subtitle: const Text('Help us improve the platform'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showFeedbackDialog,
            ),
            
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Report a Bug'),
              subtitle: const Text('Report issues or technical problems'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showBugReportDialog,
            ),
            
            const SizedBox(height: 32),
            
            // Danger Zone
            _buildSectionHeader('Account Management', Icons.warning, color: Colors.red),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete your facility account'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.teal, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.teal,
    );
  }

  void _showOperatingHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Operating Hours'),
        content: const Text('This feature allows you to set your facility operating hours. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showServiceCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Categories'),
        content: const Text('This feature allows you to manage your available service categories. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(_newPasswordController.text);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Password updated successfully!')),
        );
        
        // Clear controllers
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: $e')),
        );
      }
    }
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Manage your data privacy preferences and see what information is collected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 16),
            Text('📧 Email: support@lifecareconnect.com'),
            Text('📞 Phone: +1 (555) 123-4567'),
            Text('🕒 Hours: Mon-Fri 9AM-6PM EST'),
            SizedBox(height: 16),
            Text('For technical issues, please include your facility ID and a description of the problem.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About LifeCare Connect'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LifeCare Connect Facility Portal'),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text('© 2024 LifeCare Connect'),
            Text('All rights reserved.'),
            SizedBox(height: 16),
            Text('A comprehensive healthcare management platform connecting patients, doctors, and facilities.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Help us improve the platform by sharing your feedback:'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (feedbackController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your feedback')),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Get facility data for context
                final facilityDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                
                final facilityData = facilityDoc.data() ?? {};

                // Submit feedback to Firebase
                await FirebaseFirestore.instance
                    .collection('feedback')
                    .add({
                  'userId': user.uid,
                  'userEmail': user.email,
                  'userType': 'facility',
                  'facilityName': facilityData['facilityName'] ?? facilityData['name'],
                  'feedback': feedbackController.text.trim(),
                  'category': 'general',
                  'status': 'pending',
                  'createdAt': FieldValue.serverTimestamp(),
                  'platform': 'mobile',
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Feedback submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting feedback: $e')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final bugController = TextEditingController();
    String selectedCategory = 'General';
    String selectedPriority = 'Medium';
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report a Bug'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please describe the issue you encountered:'),
                const SizedBox(height: 16),
                TextField(
                  controller: bugController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe the bug in detail...',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                const Text('Category:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['General', 'UI/UX', 'Performance', 'Crash', 'Feature Request']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Priority:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['Low', 'Medium', 'High', 'Critical']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting 
                  ? null 
                  : () async {
                      if (bugController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please describe the issue')),
                        );
                        return;
                      }
                      
                      setState(() {
                        isSubmitting = true;
                      });
                      
                      await _submitBugReport(
                        bugController.text.trim(),
                        selectedCategory,
                        selectedPriority,
                      );
                      
                      Navigator.of(context).pop();
                    },
              child: isSubmitting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBugReport(String description, String category, String priority) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get facility details
      final facilityDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final facilityData = facilityDoc.data() ?? {};
      
      // Generate ticket ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ticketId = 'BUG-${timestamp.toString().substring(timestamp.toString().length - 8)}';
      
      // Collect device info (simplified for web compatibility)
      final deviceInfo = {
        'platform': 'Flutter',
        'timestamp': DateTime.now().toIso8601String(),
        'userAgent': 'LifeCare Connect App',
      };

      await FirebaseFirestore.instance.collection('bug_reports').add({
        'ticketId': ticketId,
        'description': description,
        'category': category,
        'priority': priority,
        'status': 'Open',
        'reportedBy': user.uid,
        'reporterEmail': user.email ?? '',
        'reporterRole': 'facility',
        'reporterName': facilityData['facilityName'] ?? facilityData['name'] ?? 'Unknown Facility',
        'deviceInfo': deviceInfo,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bug report submitted successfully! Ticket ID: $ticketId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit bug report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your facility account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show final confirmation dialog
              bool? finalConfirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Final Confirmation'),
                    content: const Text(
                      'Are you absolutely sure you want to delete your facility account?\n\n'
                      'This action will:\n'
                      '• Delete all facility data\n'
                      '• Remove all services and items\n'
                      '• Cancel all pending appointments\n'
                      '• Permanently remove your facility from the platform\n\n'
                      'This action cannot be undone!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Yes, Delete Account'),
                      ),
                    ],
                  );
                },
              );

              if (finalConfirm == true) {
                try {
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 20),
                            Text('Deleting account...'),
                          ],
                        ),
                      );
                    },
                  );

                  // Implement actual account deletion with Firebase
                  final user = FirebaseAuth.instance.currentUser;
                  final facilityId = user?.uid;
                  
                  if (user == null || facilityId == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ User not authenticated'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // Use Firestore batch for atomic operations
                    final batch = FirebaseFirestore.instance.batch();
                    
                    // 1. Delete all facility subcollections (services, items, etc.)
                    final servicesQuery = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(facilityId)
                        .collection('services')
                        .get();
                    
                    for (final doc in servicesQuery.docs) {
                      batch.delete(doc.reference);
                    }
                    
                    final itemsQuery = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(facilityId)
                        .collection('items')
                        .get();
                    
                    for (final doc in itemsQuery.docs) {
                      batch.delete(doc.reference);
                    }
                    
                    // 2. Cancel all related appointments and service requests
                    final serviceRequestsQuery = await FirebaseFirestore.instance
                        .collection('service_requests')
                        .where('facilityId', isEqualTo: facilityId)
                        .get();
                    
                    for (final doc in serviceRequestsQuery.docs) {
                      batch.update(doc.reference, {
                        'status': 'cancelled',
                        'cancellationReason': 'Facility account deleted',
                        'cancelledAt': FieldValue.serverTimestamp(),
                      });
                    }
                    
                    // Cancel appointments
                    final appointmentsQuery = await FirebaseFirestore.instance
                        .collection('appointments')
                        .where('facilityId', isEqualTo: facilityId)
                        .get();
                    
                    for (final doc in appointmentsQuery.docs) {
                      batch.update(doc.reference, {
                        'status': 'cancelled',
                        'cancellationReason': 'Facility account deleted',
                        'cancelledAt': FieldValue.serverTimestamp(),
                      });
                    }
                    
                    // 3. Create audit record before deletion
                    batch.set(FirebaseFirestore.instance
                        .collection('deleted_accounts')
                        .doc(facilityId), {
                      'userId': facilityId,
                      'userType': 'facility',
                      'userEmail': user.email,
                      'deletedAt': FieldValue.serverTimestamp(),
                      'deletionReason': 'User requested account deletion',
                    });
                    
                    // 4. Delete the main facility document
                    batch.delete(FirebaseFirestore.instance
                        .collection('users')
                        .doc(facilityId));
                    
                    // Commit all Firestore operations
                    await batch.commit();
                    
                    // 5. Delete user authentication (must be last)
                    await user.delete();
                    
                    Navigator.pop(context); // Close loading dialog
                    
                    // Navigate to login screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Account deleted successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error deleting account: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    
                    // Log error for debugging
                    try {
                      await FirebaseFirestore.instance
                          .collection('deletion_errors')
                          .add({
                        'userId': facilityId,
                        'error': e.toString(),
                        'timestamp': FieldValue.serverTimestamp(),
                        'userType': 'facility',
                      });
                    } catch (_) {
                      // Ignore logging errors
                    }
                  }
                } catch (outerError) {
                  // Handle any unexpected errors
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Unexpected error: $outerError'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

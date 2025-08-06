

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

/// CHW Settings Screen following Flutter best practices
/// Includes profile management, notifications, security, and app preferences
class CHWEditProfileScreen extends StatefulWidget {
  const CHWEditProfileScreen({super.key});

  @override
  State<CHWEditProfileScreen> createState() => _CHWEditProfileScreenState();
}

class _CHWEditProfileScreenState extends State<CHWEditProfileScreen> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;
  String _language = 'English';
  String _timezone = 'Auto';

  // User info
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  /// Load user data from Firebase
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _userEmail = user.email ?? '';
        
        // Load user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          _userName = data['fullName'] ?? data['name'] ?? 'Unknown User';
          _userRole = data['role'] ?? 'CHW';
        }
      }
    } catch (e) {

      _showErrorSnackBar('Failed to load user data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load user settings from SharedPreferences or Firestore
  Future<void> _loadSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final settingsDoc = await _firestore
            .collection('user_settings')
            .doc(user.uid)
            .get();
            
        if (settingsDoc.exists) {
          final settings = settingsDoc.data()!;
          setState(() {
            _notificationsEnabled = settings['notificationsEnabled'] ?? true;
            _pushNotifications = settings['pushNotifications'] ?? true;
            _emailNotifications = settings['emailNotifications'] ?? false;
            _darkMode = settings['darkMode'] ?? false;
            _language = settings['language'] ?? 'English';
            _timezone = settings['timezone'] ?? 'Auto';
          });
        }
      }
    } catch (e) {

    }
  }

  /// Save settings to Firestore
  Future<void> _saveSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('user_settings').doc(user.uid).set({
          'notificationsEnabled': _notificationsEnabled,
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
          'darkMode': _darkMode,
          'language': _language,
          'timezone': _timezone,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        _showSuccessSnackBar('Settings saved successfully');
      }
    } catch (e) {

      _showErrorSnackBar('Failed to save settings');
    }
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Confirm logout
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await _auth.signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        _showErrorSnackBar('Logout failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          _buildUserProfileSection(),
          const SizedBox(height: 24),

          // Notifications Section
          _buildNotificationsSection(),
          const SizedBox(height: 24),

          // App Preferences Section
          _buildAppPreferencesSection(),
          const SizedBox(height: 24),

          // Account Section
          _buildAccountSection(),
          const SizedBox(height: 24),

          // Support Section
          _buildSupportSection(),
          const SizedBox(height: 32),

          // Logout Button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  /// Build user profile section
  Widget _buildUserProfileSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userRole,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/chw_dashboard/profile'),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build notifications section
  Widget _buildNotificationsSection() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Allow app to send notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            if (!value) {
              setState(() {
                _pushNotifications = false;
                _emailNotifications = false;
              });
            }
          },
        ),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications on your device'),
          value: _pushNotifications,
          onChanged: _notificationsEnabled
              ? (value) => setState(() => _pushNotifications = value)
              : null,
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive notifications via email'),
          value: _emailNotifications,
          onChanged: _notificationsEnabled
              ? (value) => setState(() => _emailNotifications = value)
              : null,
        ),
      ],
    );
  }

  /// Build app preferences section
  Widget _buildAppPreferencesSection() {
    return _buildSettingsSection(
      title: 'App Preferences',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: _darkMode,
          onChanged: (value) => setState(() => _darkMode = value),
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_language),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageSelector(),
        ),
        ListTile(
          title: const Text('Timezone'),
          subtitle: Text(_timezone),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showTimezoneSelector(),
        ),
      ],
    );
  }

  /// Build account section
  Widget _buildAccountSection() {
    return _buildSettingsSection(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        ListTile(
          title: const Text('Change Password'),
          subtitle: const Text('Update your password'),
          leading: const Icon(Icons.lock),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _changePassword(),
        ),
        ListTile(
          title: const Text('Privacy Settings'),
          subtitle: const Text('Manage your privacy preferences'),
          leading: const Icon(Icons.privacy_tip),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showPrivacySettings(),
        ),
        ListTile(
          title: const Text('Data Export'),
          subtitle: const Text('Download your data'),
          leading: const Icon(Icons.download),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _exportData(),
        ),
      ],
    );
  }

  /// Build support section
  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: 'Support',
      icon: Icons.help,
      children: [
        ListTile(
          title: const Text('Help Center'),
          subtitle: const Text('Get help and support'),
          leading: const Icon(Icons.help_center),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openHelpCenter(),
        ),
        ListTile(
          title: const Text('Contact Support'),
          subtitle: const Text('Reach out to our support team'),
          leading: const Icon(Icons.contact_support),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _contactSupport(),
        ),
        ListTile(
          title: const Text('About'),
          subtitle: const Text('App information and version'),
          leading: const Icon(Icons.info),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAbout(),
        ),
      ],
    );
  }

  /// Build settings section widget
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _confirmLogout,
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Helper methods for settings actions
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'Portuguese']
              .map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() => _language = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showTimezoneSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Auto', 'UTC', 'GMT+1', 'GMT-5']
              .map((tz) => RadioListTile<String>(
                    title: Text(tz),
                    value: tz,
                    groupValue: _timezone,
                    onChanged: (value) {
                      setState(() => _timezone = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _changePassword() {
    _showErrorSnackBar('Password change feature coming soon');
  }

  void _showPrivacySettings() {
    _showErrorSnackBar('Privacy settings feature coming soon');
  }

  void _exportData() {
    _showErrorSnackBar('Data export feature coming soon');
  }

  void _openHelpCenter() {
    _showErrorSnackBar('Help center feature coming soon');
  }

  void _contactSupport() {
    _showErrorSnackBar('Contact support feature coming soon');
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'LifeCare Connect',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_hospital, size: 48),
      children: [
        const Text('Community Health Worker Management System'),
        const SizedBox(height: 16),
        const Text('© 2025 LifeCare Connect. All rights reserved.'),
      ],
    );
  }
}

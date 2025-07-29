// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lifecare_connect/firebase_options.dart';

// Import login screens from their new locations
import '../../../chw/presentation/screens/chw_login_screen.dart';
import '../../../patient/presentation/screens/login_patient.dart';
import '../../../admin/presentation/screens/login_admin.dart';
import '../../../doctor/presentation/screens/login_doctor.dart';
import '../../../facility/presentation/screens/facility_login_screen.dart';
import '../../../patient/presentation/screens/patient_create_account.dart';
import '../../../chw/presentation/screens/chw_create_account.dart';
import '../../../doctor/presentation/screens/doctor_create_account.dart';
import '../../../facility/presentation/screens/owner_register_facility_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _showRegistrationOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select your account type:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: Icon(Icons.people_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PatientRegisterScreen()),
                  );
                },
                label: Text('Patient Account'),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: Icon(Icons.health_and_safety),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CHWCreateAccountScreen()),
                  );
                },
                label: Text('Community Health Worker (CHW)'),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: Icon(Icons.local_hospital_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorCreateAccountScreen()),
                  );
                },
                label: Text('Doctor'),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: Icon(Icons.business_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OwnerRegisterFacilityScreen()),
                  );
                },
                label: Text('Facility'),
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Note: Patient accounts are activated immediately. CHW, Doctor, and Facility accounts require admin approval before activation.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error initializing Firebase:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'LifeCare Connect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Connecting communities to quality healthcare',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Select your login type:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 25),

                    ElevatedButton.icon(
                      icon: Icon(Icons.medical_services_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CHWLoginScreen()));
                      },
                      label: Text('Community Health Worker'),
                    ),

                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      icon: Icon(Icons.people_outline),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPatient()));
                      },
                      label: Text('Patient'),
                    ),

                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      icon: Icon(Icons.local_hospital_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginDoctorScreen()));
                      },
                      label: Text('Doctor'),
                    ),

                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginAdminScreen()));
                      },
                      label: Text('Admin'),
                    ),

                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      icon: Icon(Icons.business_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityLoginScreen()));
                      },
                      label: Text('Facility / Corporate Login'),
                    ),

                    SizedBox(height: 40),
                    Divider(thickness: 1.2),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _showRegistrationOptions(context);
                      },
                      child: Text(
                        "Don't have an account? Create one",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasRedirected = false;

  void _safeGo(String route) {
    if (!_hasRedirected && mounted) {
      _hasRedirected = true;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // ❌ Not signed in — redirect to login
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentPath = GoRouter.of(context)
                .routerDelegate
                .currentConfiguration
                .uri
                .toString();

            if (currentPath != '/login') {
              _safeGo('/login');
            }
          });
          return const SizedBox.shrink();
        }

        // ✅ Signed in — check Firestore for role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (roleSnapshot.hasError || !roleSnapshot.hasData || roleSnapshot.data?.data() == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _safeGo('/login'));
              return const Scaffold(
                body: Center(child: Text('Error: Unable to fetch user role.')),
              );
            }

            final data = roleSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              switch (role) {
                case 'doctor':
                  _safeGo('/doctor_dashboard');
                  break;
                case 'patient':
                  _safeGo('/patient_dashboard');
                  break;
                case 'admin':
                  _safeGo('/admin_dashboard');
                  break;
                case 'chw':
                  _safeGo('/chw_dashboard');
                  break;
                case 'facility':
                  _safeGo('/facility_dashboard');
                  break;
                default:
                  _safeGo('/login');
              }
            });

            return const SizedBox.shrink(); // While redirecting
          },
        );
      },
    );
  }
}

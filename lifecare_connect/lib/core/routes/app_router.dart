// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import actual screens from features
import '../../features/chw/presentation/screens/chw_regular_consultations_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard.dart';
import '../../features/chw/presentation/screens/chw_dashboard.dart'; // Ensure this import is present and CHWDashboard is defined as a class
import '../../features/chw/presentation/screens/patient_registration_screen.dart';
// Removed: ANCChecklistScreen (no longer exists)
import '../../features/chw/presentation/screens/patient_list_screen.dart';
import '../../features/chw/presentation/screens/patient_health_records_screen.dart';
import '../../features/chw/presentation/screens/chw_referrals_screen.dart';
import '../../features/chw/presentation/screens/chw_create_referral_screen.dart';
import '../../features/chw/presentation/screens/chw_consultation_screen.dart';
import '../../features/chw/presentation/screens/chw_consultation_details_screen.dart';
// import '../../features/chw/presentation/screens/clinical_documentation_screen.dart';
import '../../features/patient/presentation/screens/patient_consultation_tabbed_screen.dart';
import '../../features/patient/presentation/screens/patient_referrals_screen.dart';
import '../../features/patient/presentation/screens/patient_dashboard.dart';
import '../../features/patient/presentation/screens/patient_appointment_screen.dart';
import '../../features/facility/presentation/screens/facility_dashboard.dart';
import '../../features/shared/presentation/screens/messages_screen.dart';
import '../../features/shared/presentation/screens/chat_screen.dart';
import '../../features/shared/presentation/screens/new_conversation_screen.dart';
import '../../features/admin/presentation/screens/admin_training_screen.dart';
import '../../features/shared/presentation/screens/training_materials_screen.dart';
import '../../features/chw/presentation/screens/chw_training_screen.dart';
import '../../features/chw/presentation/screens/chw_profile_screen.dart';
import '../../features/chw/presentation/screens/chw_edit_profile_screen.dart';
import '../../features/chw/presentation/screens/chw_profile_edit_screen.dart';
import '../../features/chw/presentation/screens/chw_appointments_screen.dart';

class AppRouter {
  static GoRouter get router => _router;
  
  static final _router = GoRouter(
    initialLocation: '/login',
    redirect: _redirect,
    routes: [
      // Custom routes for CHW consultation flows
      GoRoute(
        path: '/chw_anc_consultation_details',
        name: 'chw-anc-consultation-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // Merge appointmentType into appointmentData if present
          final appointmentData = Map<String, dynamic>.from(extra?['appointmentData'] ?? {});
          if (extra?['appointmentType'] != null) {
            appointmentData['appointmentType'] = extra?['appointmentType'];
          }
          return CHWConsultationDetailsScreen(
            appointmentId: extra?['appointmentId'] ?? '',
            patientId: extra?['patientId'] ?? '',
            patientName: extra?['patientName'] ?? '',
            appointmentData: appointmentData,
          );
        },
      ),
      GoRoute(
        path: '/clinical_documentation',
        name: 'clinical-documentation',
          builder: (context, state) {
            // ...existing code or new screen logic...
            return Container(); // Placeholder for the new screen logic
          },
      ),
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin_dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'approvals',
            name: 'admin-approvals',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: 'facilities',
            name: 'admin-facilities',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'doctors',
            name: 'admin-doctors',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'admin-analytics',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'training',
            name: 'admin-training',
            builder: (context, state) => const AdminTrainingScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'admin-settings',
            builder: (context, state) => Container(),
          ),
        ],
      ),
      
      // Doctor Routes
      GoRoute(
        path: '/doctor_dashboard',
        name: 'doctor-dashboard',
        builder: (context, state) => const DoctorDashboard(),
        routes: [
          GoRoute(
            path: 'patients',
            name: 'doctor-patients',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'appointments',
            name: 'doctor-appointments',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'consultation',
            name: 'doctor-consultation',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'referrals',
            name: 'doctor-referrals',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'messages',
            name: 'doctor-messages',
            builder: (context, state) => const MessagesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'doctor-new-conversation',
                builder: (context, state) => const NewConversationScreen(),
              ),
              GoRoute(
                path: 'chat/:conversationId',
                name: 'doctor-chat',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChatScreen(
                    conversationId: conversationId,
                    otherParticipantName: extra?['otherParticipantName'] ?? 'Unknown',
                    otherParticipantRole: extra?['otherParticipantRole'] ?? 'USER',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'analytics',
            name: 'doctor-analytics',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'profile',
            name: 'doctor-profile',
            builder: (context, state) => Container(),
          ),
        ],
      ),
      
      // CHW Routes
      GoRoute(
        path: '/chw_dashboard',
        name: 'chw-dashboard',
        builder: (context, state) => const CHWDashboard(),
        routes: [
          GoRoute(
            path: 'patients',
            name: 'chw-patients',
            builder: (context, state) => const ChwPatientListScreen(),
          ),
          GoRoute(
            path: 'register_patient',
            name: 'chw-register-patient',
            builder: (context, state) => const PatientRegistrationScreen(isCHW: true),
          ),
          GoRoute(
            path: 'registration',
            name: 'chw-registration',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'appointments',
            name: 'chw-appointments',
            // builder: (context, state) => const CHWAppointmentsScreen(),
            builder: (context, state) => CHWAppointmentsScreen(),
          ),
          // Book Appointment is now handled as a modal/dialog in CHWAppointmentsScreen. No separate route needed.
          GoRoute(
            path: 'referrals',
            name: 'chw-referrals',
            builder: (context, state) => const CHWReferralsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'chw-create-referral',
                builder: (context, state) => const CHWCreateReferralScreen(),
              ),
            ],
          ),
          GoRoute(
        path: 'consultations',
        name: 'chw-consultations',
        builder: (context, state) => CHWRegularConsultationsScreen(),
        routes: [
          // Removed: CHWCreateConsultationScreen (no longer exists)
        ],
      ),
          GoRoute(
            path: 'regular-consultations',
            name: 'chw-regular-consultations',
            builder: (context, state) => CHWAppointmentsScreen(initialTab: 1),
          ),
          GoRoute(
            path: 'messages',
            name: 'chw-messages',
            builder: (context, state) => const MessagesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'chw-new-conversation',
                builder: (context, state) => const NewConversationScreen(),
              ),
              GoRoute(
                path: 'chat/:conversationId',
                name: 'chw-chat',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChatScreen(
                    conversationId: conversationId,
                    otherParticipantName: extra?['otherParticipantName'] ?? 'Unknown',
                    otherParticipantRole: extra?['otherParticipantRole'] ?? 'USER',
                  );
                },
              ),
            ],
          ),
          // Removed: ANCChecklistScreen route (no longer exists)
          // Removed: CHWANCConsultationScreen (no longer exists)
          // If ANC/PNC details are needed, use chw_anc_consultation_details_screen.dart instead.
          GoRoute(
            path: 'patient_health_records',
            name: 'chw-patient-health-records',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return PatientHealthRecordsScreen(
                patientId: extra?['patientId'] ?? '',
                patientName: extra?['patientName'] ?? 'Unknown Patient',
              );
            },
          ),
          GoRoute(
            path: 'training',
            name: 'chw-training',
            builder: (context, state) => const CHWTrainingScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'chw-profile',
            builder: (context, state) => const CHWProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'chw-settings',
            builder: (context, state) => const CHWEditProfileScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            name: 'chw-edit-profile',
            builder: (context, state) => const CHWProfileEditScreen(),
          ),
        ],
      ),
      
      // Patient Routes
      GoRoute(
        path: '/patient_dashboard',
        name: 'patient-dashboard',
        builder: (context, state) => const PatientDashboard(),
        routes: [
          GoRoute(
            path: 'appointments',
            name: 'patient-appointments',
            builder: (context, state) => const PatientAppointmentsScreen(),
          ),
          GoRoute(
            path: 'consultations',
            name: 'patient-consultations',
            builder: (context, state) => const PatientConsultationTabbedScreen(),
          ),
          GoRoute(
            path: 'referrals',
            name: 'patient-referrals',
            builder: (context, state) => const PatientReferralsScreen(),
          ),
          GoRoute(
            path: 'messages',
            name: 'patient-messages',
            builder: (context, state) => const MessagesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'patient-new-conversation',
                builder: (context, state) => const NewConversationScreen(),
              ),
              GoRoute(
                path: 'chat/:conversationId',
                name: 'patient-chat',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChatScreen(
                    conversationId: conversationId,
                    otherParticipantName: extra?['otherParticipantName'] ?? 'Unknown',
                    otherParticipantRole: extra?['otherParticipantRole'] ?? 'USER',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'health-records',
            name: 'patient-health-records',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'profile',
            name: 'patient-profile',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'training',
            name: 'patient-training',
            builder: (context, state) => const TrainingMaterialsScreen(userRole: 'patient'),
          ),
        ],
      ),
      
      // Facility Routes
      GoRoute(
        path: '/facility_dashboard',
        name: 'facility-dashboard',
        builder: (context, state) => const FacilityDashboard(),
        routes: [
          GoRoute(
            path: 'staff',
            name: 'facility-staff',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'appointments',
            name: 'facility-appointments',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: 'patients',
            name: 'facility-patients',
            builder: (context, state) => Container(),
          ),
        ],
      ),
      
      // Shared Routes
      GoRoute(
        path: '/training-materials',
        name: 'training-materials',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final userRole = extra?['userRole'] ?? 'chw';
          return TrainingMaterialsScreen(userRole: userRole);
        },
      ),
      
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MessagesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'new-conversation',
            builder: (context, state) => const NewConversationScreen(),
          ),
          GoRoute(
            path: 'chat/:conversationId',
            name: 'chat',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return ChatScreen(
                conversationId: conversationId,
                otherParticipantName: extra?['otherParticipantName'] ?? 'Unknown',
                otherParticipantRole: extra?['otherParticipantRole'] ?? 'USER',
              );
            },
          ),
        ],
      ),

      // Consultation Routes
      GoRoute(
        path: '/chw_consultation',
        name: 'chw-consultation-standalone',
        builder: (context, state) => const CHWConsultationScreen(),
      ),
    ],
  );
  
  static String? _redirect(context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isOnLoginPage = state.fullPath == '/login';
    
    // If not logged in and not on login page, redirect to login
    if (!isLoggedIn && !isOnLoginPage) {
      return '/login';
    }
    
    // If logged in and on login page, redirect based on user role
    if (isLoggedIn && isOnLoginPage) {
      // Use a more sophisticated role resolution approach
      return _getRouteForUserRole(user);
    }
    
    return null; // No redirect needed
  }
  
  /// Helper method to determine route based on user role
  static String _getRouteForUserRole(User user) {
    // Simple email-based routing (for immediate resolution)
    // This provides a working solution while the app can be enhanced later
    final email = user.email?.toLowerCase() ?? '';
    
    // Check for admin users
    if (email.contains('admin') || email.startsWith('admin@')) {
      return '/admin_dashboard';
    } 
    // Check for doctor users  
    else if (email.contains('doctor') || email.contains('dr.') || email.startsWith('doctor@')) {
      return '/doctor_dashboard';
    }
    // Check for CHW users
    else if (email.contains('chw') || email.startsWith('chw@')) {
      return '/chw_dashboard';
    }
    // Check for facility users
    else if (email.contains('facility') || email.contains('hospital') || 
             email.contains('clinic') || email.startsWith('facility@')) {
      return '/facility_dashboard';
    }
    // Default to patient dashboard
    else {
      return '/patient_dashboard';
    }
  }
}

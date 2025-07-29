import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

class LifeCareApp extends StatelessWidget {
  const LifeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // You can add global loading states, error handling, etc. here
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}

// NOTE: Ensure all CHW dashboard routes are registered in AppRouter.router
// Example:
// GoRoute(path: '/chw_dashboard/profile', builder: (context, state) => ProfileScreen()),
// ...repeat for all dashboard routes...

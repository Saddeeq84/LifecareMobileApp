// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../sharedScreen/register_role_selection.dart';

class CHWLoginScreen extends StatefulWidget {
  const CHWLoginScreen({super.key});

  @override
  State<CHWLoginScreen> createState() => _CHWLoginScreenState();
}

class _CHWLoginScreenState extends State<CHWLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      _showSnackBar('Firebase init failed: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        _showSnackBar('Login failed. Try again.');
        setState(() => isLoading = false);
        return;
      }

      if (!user.emailVerified) {
        _showSnackBar('Please verify your email before logging in.');
        setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        _showSnackBar('No user profile found. Contact admin.');
        setState(() => isLoading = false);
        return;
      }

      final data = doc.data()!;
      final role = data['role'];
      final isApproved = data['isApproved'] ?? false;

      if (role == null || role.toString().trim().isEmpty) {
        _showSnackBar('No role assigned to this account. Contact admin.');
        setState(() => isLoading = false);
        return;
      }

      if (['chw', 'doctor', 'facility'].contains(role) && !isApproved) {
        _showSnackBar('Your account is pending admin approval.');
        setState(() => isLoading = false);
        return;
      }

      print('✅ CHW role detected: $role');
      await _userService.saveUserRole(role);
      await _userService.navigateBasedOnRole(context);
    } catch (e) {
      _showSnackBar('Login failed: ${_extractMessage(e)}');
      setState(() => isLoading = false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};
      final role = data['role'];
      final isApproved = data['isApproved'] ?? false;

      if (role == null || role.toString().trim().isEmpty) {
        _showSnackBar('No role assigned to this account. Contact admin.');
        setState(() => isLoading = false);
        return;
      }

      if (['chw', 'doctor', 'facility'].contains(role) && !isApproved) {
        _showSnackBar('Your account is pending admin approval.');
        await _authService.signOut();
        setState(() => isLoading = false);
        return;
      }

      print('✅ Google login role: $role');
      await _userService.saveUserRole(role);
      await _userService.navigateBasedOnRole(context);
    } catch (e) {
      _showSnackBar('Google sign-in failed: ${_extractMessage(e)}');
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (!email.contains('@')) {
      _showSnackBar('Enter a valid email address');
      return;
    }

    try {
      await _authService.sendPasswordReset(email);
      _showSnackBar('Password reset email sent.');
    } catch (e) {
      _showSnackBar('Failed to send reset email: ${_extractMessage(e)}');
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _authService.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showSnackBar('Verification email sent.');
      } else {
        _showSnackBar('Email is already verified or not signed in.');
      }
    } catch (e) {
      _showSnackBar('Could not send verification email: ${_extractMessage(e)}');
    }
  }

  String _extractMessage(dynamic e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW Login'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: height * 0.95,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login as Community Health Worker',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value == null || !value.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Enter 6+ character password' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: isLoading ? null : handleLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: isLoading ? null : resetPassword,
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: isLoading ? null : resendVerificationEmail,
                  child: const Text('Resend verification email'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : handleGoogleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
                const Spacer(),
                const Divider(height: 30),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterRoleSelectionScreen(),
                            ),
                          );
                        },
                  child: const Text("Don't have an account? Create one"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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

      if (user != null) {
        if (!user.emailVerified) {
          _showSnackBar('Please verify your email before logging in.');
          setState(() => isLoading = false);
          return;
        }

        await _userService.saveUserRole('chw');
        await _userService.navigateBasedOnRole(context);
      }
    } catch (e) {
      _showSnackBar('Login failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _userService.saveUserRole('chw');
        await _userService.navigateBasedOnRole(context);
      }
    } catch (e) {
      _showSnackBar('Google sign-in failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      _showSnackBar('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _authService.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showSnackBar('Verification email sent.');
      } else {
        _showSnackBar('Email is already verified or no user signed in.');
      }
    } catch (e) {
      _showSnackBar('Could not send verification email: ${e.toString()}');
    }
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
        title: const Text(
          'CHW Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';

class FacilityLoginScreen extends StatefulWidget {
  const FacilityLoginScreen({super.key});

  @override
  State<FacilityLoginScreen> createState() => _FacilityLoginScreenState();
}

class _FacilityLoginScreenState extends State<FacilityLoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save the role "facility" in Firestore
      await _userService.saveUserRole('facility');

      // Navigate based on role
      await _userService.navigateBasedOnRole(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facility Login"),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                "Login to manage your facility",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: loading ? null : handleLogin,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: loading ? null : resetPassword,
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/facility_register');
                      },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

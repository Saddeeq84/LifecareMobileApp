// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class PatientRegistrationForm extends StatefulWidget {
  final bool isCHW;

  const PatientRegistrationForm({super.key, required this.isCHW});

  @override
  State<PatientRegistrationForm> createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId;
  late TabController _tabController;

  bool get _registerWithEmail => _tabController.index == 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String uid;

      // Save current CHW credentials for re-login (if CHW is creating an account)
      final chwUser = FirebaseAuth.instance.currentUser;
      final chwUid = chwUser?.uid;
      final chwEmail = chwUser?.email;

      if (_registerWithEmail) {
        // Email-based FirebaseAuth registration (for both CHW or self-registration)
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        uid = userCredential.user!.uid;
      } else {
        // Phone-based registration with OTP verification
        if (!_isOtpSent) {
          // First step: Send OTP
          await _sendOTP();
          return; // Exit early, wait for OTP verification
        } else {
          // Second step: Verify OTP and complete registration
          uid = await _verifyOTPAndCreateAccount();
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneNumberController.text.trim(),
        'role': 'patient',
        'createdBy': widget.isCHW ? chwUid : null,
        'registrationMethod':
            widget.isCHW ? 'CHW-${_registerWithEmail ? 'email' : 'phone'}' : (_registerWithEmail ? 'email' : 'phone'),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update UserService cache
      await _userService.saveUserRole('patient');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isCHW ? 'Patient registered successfully' : 'Registration successful')),
        );
      }

      if (widget.isCHW) {
        // Handle CHW workflow - sign out patient and prompt CHW to re-authenticate
        await _handleCHWReAuthentication(chwEmail, chwUid);
      } else {
        // If patient self-registered, go to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/patient_dashboard');
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCHWReAuthentication(String? chwEmail, String? chwUid) async {
    try {
      // Sign out the newly created patient account
      await FirebaseAuth.instance.signOut();
      
      // Clear the form
      _clearForm();

      if (mounted) {
        // Show dialog prompting CHW to re-authenticate
        final shouldReAuth = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Patient Registered Successfully'),
              content: const Text(
                'The patient account has been created. Please log back in with your CHW credentials to continue registering more patients.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Log In Now'),
                ),
              ],
            );
          },
        );

        if (shouldReAuth == true) {
          // Navigate to login screen with CHW context
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          // Show success message and stay on current screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient registered. Remember to log back in to continue your CHW duties.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('CHW re-authentication error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Re-authentication error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendOTP() async {
    final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }

    // Add country code if not present
    String formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+1$phoneNumber';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          setState(() {
            _isOtpSent = true;
            _isLoading = false;
          });
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Phone verification failed: ${e.message}');
        throw Exception('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to your phone number')),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<String> _verifyOTPAndCreateAccount() async {
    if (_verificationId == null || _otpController.text.trim().isEmpty) {
      throw Exception('Please enter the OTP sent to your phone');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user == null) {
      throw Exception('Phone verification failed');
    }

    return userCredential.user!.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
    _otpController.clear();
    setState(() {
      _isOtpSent = false;
      _verificationId = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.teal,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Use Email'),
              Tab(text: 'Use Phone'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmailForm(),
                  _buildPhoneForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return ListView(
      children: [
        _buildFullNameField(),
        const SizedBox(height: 10),
        _buildEmailField(),
        const SizedBox(height: 10),
        _buildPasswordField(), // Always show password field when using email
        const SizedBox(height: 20),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return ListView(
      children: [
        _buildFullNameField(),
        const SizedBox(height: 10),
        _buildPhoneField(),
        const SizedBox(height: 10),
        if (_isOtpSent) ...[
          _buildOTPField(),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _isOtpSent = false;
                _verificationId = null;
                _otpController.clear();
              });
            },
            child: const Text('Change Phone Number'),
          ),
        ],
        const SizedBox(height: 20),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: const InputDecoration(labelText: 'Full Name'),
      validator: (value) => value == null || value.isEmpty ? 'Enter your full name' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email Address'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          value == null || !value.contains('@') ? 'Enter a valid email' : null,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneNumberController,
      decoration: const InputDecoration(labelText: 'Phone Number'),
      keyboardType: TextInputType.phone,
      validator: (value) =>
          value == null || value.length < 10 ? 'Enter a valid phone number' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) =>
          value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
    );
  }

  Widget _buildOTPField() {
    return TextFormField(
      controller: _otpController,
      decoration: const InputDecoration(
        labelText: 'Enter OTP',
        hintText: '6-digit code sent to your phone',
      ),
      keyboardType: TextInputType.number,
      maxLength: 6,
      validator: (value) =>
          value == null || value.length != 6 ? 'Enter valid 6-digit OTP' : null,
    );
  }

  Widget _buildSubmitButton() {
    String buttonText;
    if (_registerWithEmail) {
      buttonText = widget.isCHW ? 'Register Patient' : 'Create Account';
    } else {
      if (_isOtpSent) {
        buttonText = 'Verify OTP & Register';
      } else {
        buttonText = 'Send OTP';
      }
    }

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
            icon: Icon(_registerWithEmail 
                ? Icons.person_add 
                : (_isOtpSent ? Icons.verified : Icons.sms)),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: _register,
          );
  }
}

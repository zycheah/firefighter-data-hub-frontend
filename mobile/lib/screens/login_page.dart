import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/location_background_service.dart';
import '../services/location_preferences_service.dart';
import 'forgot_password_page.dart';
import 'main_navigation.dart';
import 'signup_page.dart';
import 'manual_verify_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Login class Variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        await LocationPreferencesService().setIsTrackingEnabled(true);
        await LocationBackgroundService().resyncTrackingFromPreferences();

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      } else {
        final message = _authService.lastAuthError ??
            'Invalid email or password';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connection timed out. Check that the backend is running and '
              'AppConfig baseUrl is reachable from this device.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openManualVerificationPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ManualVerifyEmailPage(),
      ),
    );
  }

  void _openSignupPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );
  }

  void _openForgotPasswordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 80,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SmokeRead',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 8),
                  // const Text(
                  //   'Data Hub',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     color: Colors.grey,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _openForgotPasswordPage,
                      child: const Text('Forgot password?'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _isLoading ? null : _openSignupPage,
                    child: const Text('Don\'t have an account? Sign up'),
                  ),

                  TextButton(
                    onPressed: _isLoading ? null : _openManualVerificationPage,
                    child: const Text(
                      'Already have a verification token? Verify email',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
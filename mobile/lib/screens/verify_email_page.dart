import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? token;

  const VerifyEmailPage({super.key, required this.token});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isSuccess = false;
  String _message = 'Verifying your email...';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    final token = widget.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Invalid verification link. Token is missing.';
      });
      return;
    }

    final result = await _authService.verifyEmailToken(token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = result['success'] == true;
      _message = result['message'] ?? 'Verification failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLoading
                          ? Icons.mark_email_read_outlined
                          : _isSuccess
                              ? Icons.check_circle
                              : Icons.error,
                      size: 72,
                      color: _isLoading
                          ? Colors.orange
                          : _isSuccess
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isLoading
                          ? 'Verifying Email'
                          : _isSuccess
                              ? 'Email Verified'
                              : 'Verification Failed',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Go to Login'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
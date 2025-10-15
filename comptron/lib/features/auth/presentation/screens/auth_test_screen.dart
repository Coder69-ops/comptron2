import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Test User');

  bool _isLoading = false;
  String _result = '';

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final authService = await AuthService.getInstance();
      final user = await authService.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );

      setState(() {
        _result =
            'Sign up successful!\nUser: ${user.name} (${user.email})\nRole: ${user.role}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Sign up failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final authService = await AuthService.getInstance();
      final user = await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _result =
            'Sign in successful!\nUser: ${user.name} (${user.email})\nRole: ${user.role}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Sign in failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Authentication Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Test Sign Up',
                            onPressed: _isLoading ? null : _testSignUp,
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Test Sign In',
                            onPressed: _isLoading ? null : _testSignIn,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _result.isEmpty ? 'No results yet...' : _result,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

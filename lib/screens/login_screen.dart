import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .login(_usernameController.text, _passwordController.text);

      if (success && mounted) {
        context.go('/discom-selection');
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final usernameController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your username and new password. For security reasons, please contact your administrator if you need assistance.',
                ),
                const SizedBox(height: 24),
                InfoLabel(
                  label: 'Username',
                  child: TextBox(
                    controller: usernameController,
                    placeholder: 'Enter your username',
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'New Password',
                  child: PasswordBox(
                    controller: newPasswordController,
                    placeholder: 'Enter new password',
                    revealMode: PasswordRevealMode.peek,
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'Confirm Password',
                  child: PasswordBox(
                    controller: confirmPasswordController,
                    placeholder: 'Confirm new password',
                    revealMode: PasswordRevealMode.peek,
                  ),
                ),
                const SizedBox(height: 16),
                InfoBar(
                  title: const Text('Admin Reset'),
                  content: const Text(
                    'Use default admin credentials (admin/admin123) to reset any user password.',
                  ),
                  severity: InfoBarSeverity.info,
                ),
              ],
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final username = usernameController.text.trim();
                  final newPassword = newPasswordController.text;
                  final confirmPassword = confirmPasswordController.text;

                  if (username.isEmpty) {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => ContentDialog(
                              title: const Text('Error'),
                              content: const Text(
                                'Please enter your username.',
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                    return;
                  }

                  if (newPassword.isEmpty || newPassword.length < 6) {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => ContentDialog(
                              title: const Text('Error'),
                              content: const Text(
                                'Password must be at least 6 characters long.',
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => ContentDialog(
                              title: const Text('Error'),
                              content: const Text('Passwords do not match.'),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                    return;
                  }

                  // Attempt admin reset using default credentials
                  final authService = AuthService();
                  final adminUser = await authService.login(
                    'admin',
                    'admin123',
                  );

                  if (adminUser != null && adminUser['is_admin'] == true) {
                    final success = await authService.adminResetPassword(
                      username,
                      newPassword,
                    );

                    if (context.mounted) {
                      if (success) {
                        await showDialog(
                          context: context,
                          builder:
                              (context) => ContentDialog(
                                title: const Text('Success'),
                                content: Text(
                                  'Password reset successful for user "$username". You can now login with your new password.',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      } else {
                        await showDialog(
                          context: context,
                          builder:
                              (context) => ContentDialog(
                                title: const Text('Error'),
                                content: Text(
                                  'User "$username" not found. Please check the username and try again.',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      }
                    }
                  } else {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => ContentDialog(
                              title: const Text('Error'),
                              content: const Text(
                                'Password reset requires admin authentication. Please contact your administrator.',
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  }
                },
                child: const Text('Reset Password'),
              ),
            ],
          ),
    );

    usernameController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    if (result == true && mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Title
              Icon(
                FluentIcons.bill,
                size: 64,
                color: FluentTheme.of(context).accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                'DISCOM Bill Manager',
                style: FluentTheme.of(context).typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Production-Ready Bill Management System',
                style: FluentTheme.of(context).typography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Username field
              InfoLabel(
                label: 'Username',
                child: TextBox(
                  controller: _usernameController,
                  placeholder: 'Enter username',
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLogin(),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              InfoLabel(
                label: 'Password',
                child: PasswordBox(
                  controller: _passwordController,
                  placeholder: 'Enter password',
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLogin(),
                  revealMode: PasswordRevealMode.peek,
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                InfoBar(
                  title: const Text('Login Failed'),
                  content: Text(_errorMessage!),
                  severity: InfoBarSeverity.error,
                ),
                const SizedBox(height: 16),
              ],

              // Login button
              FilledButton(
                onPressed: _isLoading ? null : _handleLogin,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: ProgressRing(strokeWidth: 3),
                        )
                        : const Text('Login'),
              ),
              const SizedBox(height: 16),

              // Forgot password link
              Center(
                child: HyperlinkButton(
                  onPressed: _isLoading ? null : _showForgotPasswordDialog,
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 32),

              // Default credentials info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Admin Credentials',
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Username: admin',
                      style: FluentTheme.of(context).typography.caption,
                    ),
                    Text(
                      'Password: admin123',
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

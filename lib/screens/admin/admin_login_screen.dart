import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../providers/language_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

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
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    final result = await authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      // Check if user is admin
      final isAdmin = await authService.isAdmin();

      if (isAdmin) {
        if (mounted) {
          AppRoutes.navigateAndReplace(context, AppRoutes.adminDashboard);
        }
      } else {
        // Not an admin, sign out
        await authService.signOut();
        setState(() {
          _errorMessage = 'Access denied. Admin privileges required.';
        });
      }
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDesktop = AppTheme.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          languageProvider.translate('admin_login'),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppTheme.responsivePadding(context),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 400 : double.infinity,
            ),
            child: Card(
              elevation: AppTheme.elevationL,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Icon
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Title
                      Text(
                        languageProvider.translate('admin_panel'),
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppTheme.spacingS),

                      Text(
                        languageProvider.translate('admin_access_only'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            border: Border.all(color: AppTheme.errorColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: languageProvider.translate('email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'admin@restaurant.com',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return languageProvider.translate('email_required');
                          }
                          if (!value.contains('@')) {
                            return languageProvider.translate('invalid_email');
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: languageProvider.translate('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return languageProvider.translate('password_required');
                          }
                          if (value.length < 6) {
                            return languageProvider.translate('password_too_short');
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          languageProvider.translate('login'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          _showForgotPasswordDialog();
                        },
                        child: Text(
                          languageProvider.translate('forgot_password'),
                          style: TextStyle(color: AppTheme.secondaryColor),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Info Text
                      Text(
                        languageProvider.translate('admin_info'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('forgot_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageProvider.translate('reset_password_info'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingL),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: languageProvider.translate('email'),
                hintText: 'admin@restaurant.com',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authService = Provider.of<AuthService>(context, listen: false);
                final result = await authService.sendPasswordResetEmail(
                  emailController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.isSuccess
                            ? languageProvider.translate('reset_email_sent')
                            : result.message ?? languageProvider.translate('error'),
                      ),
                      backgroundColor: result.isSuccess
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(languageProvider.translate('send_reset_email')),
          ),
        ],
      ),
    );
  }
}
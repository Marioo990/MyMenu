import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/language_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Whitelist adminów - możesz przenieść do Firestore
  static const List<String> adminWhitelist = [
    'admin@restaurant.com',
    'pizza99069@gmail.com', // Dodaj swój email tutaj
    // Dodaj więcej emaili adminów
  ];

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
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
                      'Sign in with your authorized Google account',
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

                    // Google Sign-In Button
                    _buildGoogleSignInButton(),

                    const SizedBox(height: AppTheme.spacingL),

                    // Info Text
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Text(
                                'Admin Access Requirements:',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          _buildRequirement('Google account with verified email'),
                          _buildRequirement('Email on admin whitelist'),
                          _buildRequirement('Active admin status'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Back to Menu Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Text(
                        'Back to Menu',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
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

  Widget _buildGoogleSignInButton() {
    return Material(
      elevation: _isLoading ? 0 : 2,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: InkWell(
        onTap: _isLoading ? null : _handleGoogleSignIn,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: _isLoading ? Colors.grey.shade300 : Colors.grey.shade400,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                // Google "G" Logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3C4043),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingL, top: AppTheme.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create Google Auth Provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Set custom parameters
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      // Sign in with popup (for web)
      final UserCredential userCredential =
      await _auth.signInWithPopup(googleProvider);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to get user information');
      }

      print('✅ User signed in: ${user.email}');
      print('   Email Verified: ${user.emailVerified}');

      // Check if email is verified
      if (!user.emailVerified) {
        await _auth.signOut();
        setState(() {
          _errorMessage = 'Email not verified. Please verify your Google account.';
          _isLoading = false;
        });
        return;
      }

      // Check if user is admin
      final bool isAdmin = await _checkAdminAccess(user);

      if (!isAdmin) {
        await _auth.signOut();
        setState(() {
          _errorMessage = 'Access denied. You are not authorized as an admin.';
          _isLoading = false;
        });
        return;
      }

      // Save user data to Firestore
      await _saveUserToFirestore(user, isAdmin);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);

      // Show welcome message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${user.displayName ?? "Admin"}!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getFirebaseErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign in failed: ${e.toString()}';
      });
    }
  }

  Future<bool> _checkAdminAccess(User user) async {
    if (user.email == null) return false;

    // Method 1: Check hardcoded whitelist
    if (adminWhitelist.contains(user.email)) {
      print('✅ Admin access granted (whitelist)');
      return true;
    }

    // Method 2: Check in Firestore
    try {
      // Check by UID
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
        print('✅ Admin access granted (Firestore UID)');
        return true;
      }

      // Check by email
      final adminByEmail = await _firestore
          .collection('admins')
          .doc(user.email!)
          .get();

      if (adminByEmail.exists && adminByEmail.data()?['isActive'] == true) {
        print('✅ Admin access granted (Firestore email)');
        return true;
      }
    } catch (e) {
      print('⚠️ Error checking admin access: $e');
    }

    print('❌ Admin access denied');
    return false;
  }

  Future<void> _saveUserToFirestore(User user, bool isAdmin) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'isAdmin': isAdmin,
        'lastLogin': FieldValue.serverTimestamp(),
        'provider': 'google',
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ User data saved to Firestore');
    } catch (e) {
      print('⚠️ Error saving user data: $e');
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked. Please allow popups for this site.';
      case 'popup-closed-by-user':
        return 'Sign-in cancelled.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for sign-in.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return AuthResult.success(user: credential.user!);
      } else {
        return const AuthResult.error(message: 'Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Create user with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user!.updateDisplayName(displayName);
        }

        return AuthResult.success(user: credential.user!);
      } else {
        return const AuthResult.error(message: 'Failed to create account');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Update password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        return const AuthResult.error(message: 'No user logged in');
      }

      await currentUser!.updatePassword(newPassword);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Update email
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      if (currentUser == null) {
        return const AuthResult.error(message: 'No user logged in');
      }

      await currentUser!.updateEmail(newEmail);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Reauthenticate user
  Future<AuthResult> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      if (currentUser == null) {
        return const AuthResult.error(message: 'No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      if (currentUser == null) {
        return const AuthResult.error(message: 'No user logged in');
      }

      await currentUser!.delete();
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  // Refresh user token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (currentUser == null) return null;
    return await currentUser!.getIdToken(forceRefresh);
  }

  // Get user claims (for role-based access)
  Future<Map<String, dynamic>> getUserClaims() async {
    if (currentUser == null) return {};

    final token = await currentUser!.getIdTokenResult();
    return token.claims ?? {};
  }

  // Check if user has admin role
  Future<bool> isAdmin() async {
    final claims = await getUserClaims();
    return claims['admin'] == true;
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;

  const AuthResult._({
    required this.isSuccess,
    this.message,
    this.user,
  });

  const AuthResult.success({User? user})
      : this._(isSuccess: true, user: user);

  const AuthResult.error({required String message})
      : this._(isSuccess: false, message: message);
}

// Auth state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}
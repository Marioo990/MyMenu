import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '927400788077-your-client-id.apps.googleusercontent.com' // Zastąp swoim Client ID jeśli trzeba
        : null,
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  // Usunięto hardcoded adminWhitelist - teraz używamy tylko Firestore

  // Stream zmian stanu autoryzacji
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obecny użytkownik
  User? get currentUser => _auth.currentUser;

  // Czy użytkownik jest zalogowany
  bool get isLoggedIn => currentUser != null;

  /// Główna metoda logowania przez Google OAuth 2.0
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In process...');

      if (kIsWeb) {
        // Flutter Web - użyj popup
        return await _signInWithGoogleWeb();
      } else {
        // Mobile - standardowy flow
        return await _signInWithGoogleMobile();
      }
    } catch (e, stackTrace) {
      print('❌ Google Sign-In error: $e');
      print('Stack trace: $stackTrace');
      return AuthResult.error(
        message: 'Failed to sign in with Google: ${e.toString()}',
      );
    }
  }

  /// Web implementation - używa signInWithPopup
  Future<AuthResult> _signInWithGoogleWeb() async {
    try {
      // Utwórz Google Auth Provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Dodaj scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Ustaw parametry
      googleProvider.setCustomParameters({
        'prompt': 'select_account', // Zawsze pokazuj wybór konta
        'access_type': 'offline',
        'include_granted_scopes': 'true',
      });

      // Sign in with popup
      final UserCredential userCredential =
      await _auth.signInWithPopup(googleProvider);

      return await _processSignInResult(userCredential);
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      return _handleFirebaseAuthError(e);
    }
  }

  /// Mobile implementation - używa GoogleSignIn package
  Future<AuthResult> _signInWithGoogleMobile() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResult.error(message: 'Sign in cancelled by user');
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      return await _processSignInResult(userCredential);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    }
  }

  /// Przetwarzanie wyniku logowania
  Future<AuthResult> _processSignInResult(UserCredential userCredential) async {
    final User? user = userCredential.user;

    if (user == null) {
      return const AuthResult.error(message: 'Failed to get user information');
    }

    print('✅ User signed in: ${user.email}');
    print('   Display Name: ${user.displayName}');
    print('   Email Verified: ${user.emailVerified}');
    print('   Photo URL: ${user.photoURL}');

    // 1. Sprawdź czy email jest zweryfikowany
    if (!user.emailVerified) {
      await signOut();
      return const AuthResult.error(
        message: 'Email not verified. Please verify your Google account email.',
      );
    }

    // 2. Sprawdź czy użytkownik jest adminem (teraz korzysta z poprawionej metody checkAdminAccess)
    final bool isAdmin = await checkAdminAccess(user);

    // 3. Zapisz dane użytkownika do Firestore
    await _saveUserToFirestore(user, isAdmin);

    // 4. Jeśli to panel admina ale user nie jest adminem - wyloguj
    if (_isAdminRoute() && !isAdmin) {
      await signOut();
      return const AuthResult.error(
        message: 'Access denied. Admin privileges required.',
        code: 'admin-access-denied',
      );
    }

    return AuthResult.success(
      user: user,
      isAdmin: isAdmin,
      additionalData: {
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
      },
    );
  }

  /// Sprawdzanie czy użytkownik jest adminem (Dynamicznie z Firestore)
  Future<bool> checkAdminAccess(User user) async {
    if (user.email == null) return false;

    try {
      // Sprawdź czy istnieje dokument w kolekcji 'admins' gdzie ID to email
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.email)
          .get();

      if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
        print('✅ Admin access granted (Firestore email found)');
        return true;
      }

      // Opcjonalnie: Sprawdź po UID (jeśli dodasz admina po UID zamiast emaila)
      final adminByUid = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminByUid.exists && adminByUid.data()?['isActive'] == true) {
        print('✅ Admin access granted (Firestore UID found)');
        return true;
      }

    } catch (e) {
      print('⚠️ Error checking admin access: $e');
    }

    print('❌ Admin access denied');
    return false;
  }

  /// Zapisz dane użytkownika do Firestore
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

  /// Wylogowanie
  Future<void> signOut() async {
    try {
      // Wyloguj z Google
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }

      // Wyloguj z Firebase
      await _auth.signOut();

      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Sprawdź czy obecna trasa to admin
  bool _isAdminRoute() {
    // Implementacja zależy od twojego routingu
    // Możesz przekazać to jako parametr lub sprawdzić current route
    return false; // Zastąp własną logiką
  }

  /// Obsługa błędów Firebase Auth
  AuthResult _handleFirebaseAuthError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'account-exists-with-different-credential':
        message = 'An account already exists with a different sign-in method.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials. Please try again.';
        break;
      case 'operation-not-allowed':
        message = 'Google sign-in is not enabled. Please contact support.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No account found. Please sign up first.';
        break;
      case 'wrong-password':
        message = 'Invalid password.';
        break;
      case 'popup-blocked':
        message = 'Sign-in popup was blocked. Please allow popups for this site.';
        break;
      case 'popup-closed-by-user':
        message = 'Sign-in cancelled.';
        break;
      case 'unauthorized-domain':
        message = 'This domain is not authorized for sign-in.';
        break;
      default:
        message = 'Authentication failed: ${e.message}';
    }

    return AuthResult.error(message: message, code: e.code);
  }

  /// Pobierz dodatkowe informacje o użytkowniku
  Future<Map<String, dynamic>?> getUserClaims() async {
    if (currentUser == null) return null;

    try {
      final idTokenResult = await currentUser!.getIdTokenResult();
      return idTokenResult.claims;
    } catch (e) {
      print('❌ Error getting user claims: $e');
      return null;
    }
  }

  /// Odśwież token
  Future<String?> refreshToken() async {
    if (currentUser == null) return null;

    try {
      return await currentUser!.getIdToken(true);
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return null;
    }
  }
}

/// Wynik autoryzacji
class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? code;
  final User? user;
  final bool isAdmin;
  final Map<String, dynamic>? additionalData;

  const AuthResult._({
    required this.isSuccess,
    this.message,
    this.code,
    this.user,
    this.isAdmin = false,
    this.additionalData,
  });

  const AuthResult.success({
    User? user,
    bool isAdmin = false,
    Map<String, dynamic>? additionalData,
  }) : this._(
    isSuccess: true,
    user: user,
    isAdmin: isAdmin,
    additionalData: additionalData,
  );

  const AuthResult.error({
    required String message,
    String? code,
  }) : this._(
    isSuccess: false,
    message: message,
    code: code,
  );
}
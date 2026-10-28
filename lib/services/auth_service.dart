import 'package:firebase_auth/firebase_auth.dart';

// Handles Firebase user authentication (register, sign in, sign out, and error messages).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream that emits whenever the user logs in or logs out.
  Stream<User?> get authChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Creates a new user account, saves their display name, then signs out so they log in manually.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await _auth.signOut();
  }

  // Signs in an existing user with email and password.
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Signs out the current user.
  Future<void> logout() => _auth.signOut();

  // Translates Firebase error codes into user-friendly messages.
  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

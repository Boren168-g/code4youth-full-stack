import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  FirebaseAuth? _auth;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      print('Firebase not initialized yet');
    }
  }

  Stream<User?> get user => _auth?.authStateChanges() ?? const Stream.empty();

  Future<UserCredential?> signIn(String email, String password) async {
    if (_auth == null) return null;
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    if (_auth == null) return null;
    try {
      return await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logmap/shared/show_snackbar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;

  FirebaseAuthMethods(this._auth);

  // Logs in a user with email and password.
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Returns a stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Returns the current authenticated user.
  User? get currentUser => _auth.currentUser;

  // Signs out the current user.
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      // Handle error
      if (kDebugMode) {
        print('An error occurred during sign out: ${e.message}');
      }
    }
  }
}

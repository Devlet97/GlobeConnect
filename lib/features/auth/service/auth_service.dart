import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Future<void> checkAuthState(BuildContext context) async {
    if (isLoggedIn) {
      // Kullanıcı zaten giriş yapmışsa ana sayfaya yönlendir
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }
}

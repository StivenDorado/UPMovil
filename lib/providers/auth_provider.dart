// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  User? _fbUser;
  bool? _isArrendador;
  bool _loading = true;

  // Getter original
  User? get fbUser => _fbUser;

  // Alias para que uses `auth.user`
  User? get user => _fbUser;

  bool? get isArrendador => _isArrendador;
  bool get loading => _loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _loading = true;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _loading = true;
      notifyListeners();

      _fbUser = user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data() ?? {};
        _isArrendador = (data['role'] as String? ?? '') == 'arrendador';
      } else {
        _isArrendador = null;
      }

      _loading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> register(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'role': 'aprendiz',
    });
  }

  Future<void> sendPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  Future<UserCredential> loginWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider()
        ..addScope('https://www.googleapis.com/auth/contacts.readonly')
        ..setCustomParameters({'login_hint': 'user@example.com'});
      return FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // 1) Inicia flujo de Google Sign-In
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Usuario canceló el login
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Inicio de sesión con Google cancelado por el usuario',
        );
      }

      // 2) Obtén los tokens
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      // 3) Valida tokens
      if (accessToken == null || idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Falta el token de autenticación de Google',
        );
      }

      // 4) Crea credencial y autentica en Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      return FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  User? _fbUser;
  bool? _isArrendador;
  bool _authChecked = false;
  bool _profileLoading = false;

  // Getters públicos
  User? get user => _fbUser;
  bool get authChecked => _authChecked;
  bool get profileLoading => _profileLoading;
  bool? get isArrendador => _isArrendador;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      // 1) Ya sabemos si hay sesión
      _authChecked = true;
      notifyListeners();

      // 2) Arrancamos lectura de perfil
      _profileLoading = true;
      notifyListeners();

      _fbUser = user;

      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final data = doc.data() ?? {};
          _isArrendador = (data['role'] as String? ?? '') == 'arrendador';
        } catch (e) {
          // En caso de error dejamos el rol en false
          _isArrendador = false;
        }
      } else {
        _isArrendador = null;
      }

      // 3) Perfil ya cargado (éxito o error)
      _profileLoading = false;
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
        .set({'role': 'aprendiz'});
  }

  Future<void> sendPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  Future<UserCredential> loginWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()..addScope('https://www.googleapis.com/auth/contacts.readonly');
      return FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Login cancelado por el usuario',
        );
      }
      final googleAuth = await googleUser.authentication;
      final token = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (token == null || idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Faltan tokens de Google',
        );
      }
      final cred = GoogleAuthProvider.credential(
        accessToken: token,
        idToken: idToken,
      );
      return FirebaseAuth.instance.signInWithCredential(cred);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) await GoogleSignIn().signOut();
  }
}

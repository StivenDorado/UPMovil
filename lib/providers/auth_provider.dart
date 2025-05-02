import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _fbUser;
  bool? _isArrendador;
  bool _authChecked = false;
  bool _profileLoading = false;
  final String _apiBaseUrl = 'http://localhost:4000/api';

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
      _authChecked = true;
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

          if (data['role'] == 'arrendador') {
            _isArrendador = true;
          } else {
            await _checkArrendadorStatusApi(user);
          }
        } catch (e) {
          _isArrendador = false;
        }
      } else {
        _isArrendador = null;
      }

      _profileLoading = false;
      notifyListeners();
    });
  }

  Future<void> _checkArrendadorStatusApi(User user) async {
    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/arrendador/status/${user.uid}'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['isArrendador'] == true) {
          _isArrendador = true;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'role': 'arrendador'}, SetOptions(merge: true));
        } else {
          _isArrendador = false;
        }
      } else {
        _isArrendador = false;
      }
    } catch (e) {
      _isArrendador = false;
    }
  }

  /// Método para convertir al usuario en arrendador
  Future<bool> registerAsLandlord() async {
    if (_fbUser == null) return false;
    _profileLoading = true;
    notifyListeners();

    try {
      final token = await _fbUser!.getIdToken();
      final res = await http.post(
        Uri.parse('$_apiBaseUrl/arrendador'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': _fbUser!.uid,
          'email': _fbUser!.email,
          'name': _fbUser!.displayName ?? '',
        }),
      );

      // Comprobar respuesta
      final responseData = res.statusCode == 200 || res.statusCode == 400 
          ? json.decode(res.body) 
          : null;

      // Manejo especial para cuando el usuario ya es arrendador
      if (res.statusCode == 400 && 
          responseData != null && 
          responseData['error'] == 'El usuario ya es arrendador') {
        // El usuario ya es arrendador, actualizamos Firestore y estado local
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_fbUser!.uid)
            .set({'role': 'arrendador'}, SetOptions(merge: true));

        _isArrendador = true;
        _profileLoading = false;
        notifyListeners();
        return true; // Retornamos verdadero aunque sea código 400
      }

      // Caso de éxito normal
      if (res.statusCode == 200 || res.statusCode == 201) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_fbUser!.uid)
            .set({'role': 'arrendador'}, SetOptions(merge: true));

        _isArrendador = true;
        _profileLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('registerAsLandlord failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('registerAsLandlord error: $e');
    }

    _profileLoading = false;
    notifyListeners();
    return false;
  }

  /// Refresca el estado de arrendador desde API/Firestore
  Future<void> refreshProfile() async {
    if (_fbUser == null) return;
    _profileLoading = true;
    notifyListeners();
    await _checkArrendadorStatusApi(_fbUser!);
    _profileLoading = false;
    notifyListeners();
  }

  // Métodos de autenticación estándar
  Future<UserCredential> login(String email, String password) =>
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
      final provider = GoogleAuthProvider()
        ..addScope('https://www.googleapis.com/auth/contacts.readonly');
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
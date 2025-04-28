import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? user;
  bool loading = true;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _auth.authStateChanges().listen((firebaseUser) async {
      loading = true;
      notifyListeners();

      if (firebaseUser != null) {
        user = firebaseUser;
        try {
          // Asegurar que token no sea null
          final String token = (await firebaseUser.getIdToken(true))!;
          final bool isArrendador = await _verifyArrendador(token, firebaseUser.uid);

          if (!isArrendador) {
            final bool alreadyRegistered = await _verifyUsuario(token, firebaseUser.uid);
            if (!alreadyRegistered) {
              await _registrarUsuario(token, {
                'uid': firebaseUser.uid,
                'nombres_apellidos': firebaseUser.displayName ?? 'Nombre no proporcionado',
                'email': firebaseUser.email,
                'fotoPerfil': firebaseUser.photoURL,
              });
            }
          }
        } catch (e) {
          // Puedes manejar el error según convenga
        }
      } else {
        user = null;
      }

      loading = false;
      notifyListeners();
    });
  }

  Future<bool> _verifyArrendador(String token, String uid) async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:4000/api/arrendador'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        final match = data.firstWhere(
          (p) => p['uid']?.toString().trim() == uid.trim(),
          orElse: () => null,
        );
        if (match != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('arrendadorId', match['uid']);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _verifyUsuario(String token, String uid) async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:4000/api/usuario/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 404) return false;
      if (res.statusCode == 200) return true;
      throw Exception('Error verificando usuario');
    } catch (_) {
      return false;
    }
  }

  Future<void> _registrarUsuario(String token, Map<String, dynamic> usuarioData) async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:4000/api/usuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(usuarioData),
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Error registrando usuario');
      }
    } catch (_) {
      // handle or log
    }
  }

  // Métodos públicos

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Login cancelado');
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('arrendadorId');
    await _auth.signOut();
  }
}

/*
Dependencias en pubspec.yaml:

dependencies:
  firebase_auth: ^4.4.0
  google_sign_in: ^6.0.0
  http: ^0.13.5
  shared_preferences: ^2.0.15
  provider: ^6.0.5
*/

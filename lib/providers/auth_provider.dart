import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  bool loading = true;
  String? errorMessage;

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
          // Verificar si el usuario ya está registrado en Firestore
          final userDoc = await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
          
          if (!userDoc.exists) {
            // Si no existe, registrar al usuario en Firestore
            await _registrarUsuario({
              'uid': firebaseUser.uid,
              'nombres_apellidos': firebaseUser.displayName ?? 'Usuario',
              'email': firebaseUser.email,
              'fotoPerfil': firebaseUser.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          errorMessage = e.toString();
          notifyListeners();
        }
      } else {
        user = null;
      }

      loading = false;
      notifyListeners();
    });
  }

  Future<void> _registrarUsuario(Map<String, dynamic> usuarioData) async {
    try {
      await _firestore.collection('usuarios').doc(usuarioData['uid']).set(usuarioData);
    } catch (e) {
      errorMessage = 'Error al registrar usuario: ${e.toString()}';
      notifyListeners();
    }
  }

  // Métodos públicos para la autenticación

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      errorMessage = _handleFirebaseError(e);
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      errorMessage = null;
      return credential;
    } catch (e) {
      errorMessage = _handleFirebaseError(e);
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<UserCredential> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      errorMessage = null;
      return userCredential;
    } catch (e) {
      errorMessage = _handleFirebaseError(e);
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      errorMessage = null;
      return credential;
    } catch (e) {
      errorMessage = _handleFirebaseError(e);
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Limpiar todas las preferencias al cerrar sesión
      await _googleSignIn.signOut(); // Asegurarse de cerrar sesión en Google también
      await _auth.signOut();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Método para manejar errores de Firebase de forma más amigable
  String _handleFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe un usuario con este correo electrónico.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'email-already-in-use':
          return 'Este correo electrónico ya está registrado.';
        case 'weak-password':
          return 'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
        case 'invalid-email':
          return 'El formato del correo electrónico no es válido.';
        case 'account-exists-with-different-credential':
          return 'Ya existe una cuenta con este correo pero con otro método de inicio de sesión.';
        case 'operation-not-allowed':
          return 'Esta operación no está permitida.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde.';
        default:
          return 'Error de autenticación: ${error.code}';
      }
    }
    return error.toString();
  }
}
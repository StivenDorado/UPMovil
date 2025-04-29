import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get loading => _loading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _loading = false;
      notifyListeners();
    });
  }

  // Método para iniciar sesión con correo y contraseña
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método para registrarse con correo y contraseña
  Future<void> register(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método para recuperar contraseña
  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // Método para iniciar sesión con Google
  Future<UserCredential> loginWithGoogle() async {
    // Para web, utilizamos un enfoque diferente debido a las limitaciones
    if (kIsWeb) {
      // Configura el proveedor de Google
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({
        'login_hint': 'user@example.com'
      });

      // Inicia el flujo de autenticación de Google usando el popup
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Para dispositivos móviles, usamos el flujo estándar
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Falta el token de autenticación de Google',
        );
      }

      // Crear credencial de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Iniciar sesión con credencial
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }
}
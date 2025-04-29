import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
// Ocultamos AuthProvider de firebase para evitar conflicto con nuestro proveedor
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../providers/auth_provide.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  bool _showRegisterForm = false;

  bool get _isLogin => !_showRegisterForm;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (_isLogin) {
        await auth.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await auth.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (mounted && auth.user != null) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e.code);
    } catch (e) {
      _handleGenericError();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loginWithGoogle();
      if (mounted && auth.user != null) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } on PlatformException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      _handleGenericError();
    }
  }

  void _handleAuthError(String code) {
    String message;
    switch (code) {
      case 'user-not-found':
        message = 'Usuario no encontrado';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta';
        break;
      case 'email-already-in-use':
        message = 'El correo ya está registrado';
        break;
      case 'weak-password':
        message = 'La contraseña es muy débil';
        break;
      default:
        message = 'Error de autenticación';
    }
    setState(() => _errorMessage = message);
  }

  void _handleGenericError() {
    setState(() => _errorMessage = 'Error inesperado. Intente nuevamente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        '/logo.png',
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                              .hasMatch(value)) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_isLogin ? 'Ingresar' : 'Registrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(
                            () => _showRegisterForm = !_showRegisterForm),
                        child: Text(
                          _isLogin
                              ? '¿No tienes cuenta? Regístrate'
                              : '¿Ya tienes cuenta? Inicia Sesión',
                          style: TextStyle(color: Colors.indigo[900]),
                        ),
                      ),
                      const Divider(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/google.png',
                            height: 24,
                          ),
                          label: const Text('Continuar con Google'),
                          onPressed: _isLoading ? null : _googleSignIn,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

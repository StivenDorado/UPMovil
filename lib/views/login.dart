import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Added 'hide AuthProvider' to resolve conflict

import '../providers/auth_provider.dart'; // Your custom AuthProvider

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
  bool _showForgotPassword = false;
  String? _successMessage;

  bool get _isLogin => !_showRegisterForm && !_showForgotPassword;

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
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loginWithGoogle();

      if (mounted && auth.user != null) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } on PlatformException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor, introduce tu correo electrónico');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.sendPasswordReset(_emailController.text.trim());
      
      setState(() {
        _successMessage = 'Se ha enviado un correo con instrucciones para restablecer tu contraseña.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF275950), Color(0xFF1a3b35)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con efecto de brillo
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF88F2E8).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        width: 80,
                      ),
                    ),
                  ),
                ),

                // Card principal
                Card(
                  elevation: 10,
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: const Color(0xFF88F2E8).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _showForgotPassword
                            ? _buildForgotPasswordForm()
                            : _buildAuthForm(),
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    '© ${DateTime.now().year} | Todos los derechos reservados',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAuthForm() {
    return [
      Text(
        _showRegisterForm ? 'Regístrate' : 'Inicia Sesión',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 24),
      // Email field
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Correo Electrónico',
          prefixIcon: const Icon(Icons.email, color: Color(0xFF88F2E8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu correo';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Correo inválido';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      // Password field
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF88F2E8)),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu contraseña';
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
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      const SizedBox(height: 24),
      // Main button (login/register)
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitForm,
          icon: _showRegisterForm
              ? const Icon(Icons.person_add)
              : const Icon(Icons.login),
          label: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_showRegisterForm ? 'Registrarse' : 'Iniciar Sesión'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF2A8C82),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Toggle auth mode (login/register)
      TextButton(
        onPressed: () => setState(() {
          _showRegisterForm = !_showRegisterForm;
          _errorMessage = null;
        }),
        child: Text(
          _showRegisterForm
              ? '¿Ya tienes cuenta? Inicia Sesión'
              : '¿No tienes cuenta? Regístrate',
          style: const TextStyle(color: Color(0xFF88F2E8)),
        ),
      ),
      // Forgot password
      if (!_showRegisterForm)
        TextButton(
          onPressed: () => setState(() {
            _showForgotPassword = true;
            _errorMessage = null;
          }),
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(color: Color(0xFF88F2E8)),
          ),
        ),
      const Divider(height: 32, color: Colors.white24),
      // Google signin
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.g_mobiledata, size: 30),
          label: const Text('Continuar con Google'),
          onPressed: _isLoading ? null : _googleSignIn,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildForgotPasswordForm() {
    return [
      const Text(
        'Recuperar Contraseña',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 24),
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Correo Electrónico',
          prefixIcon: const Icon(Icons.email, color: Color(0xFF88F2E8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF41BFB3).withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
      ),
      if (_successMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _successMessage!,
              style: const TextStyle(
                color: Color(0xFF88F2E8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      if (_errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _resetPassword,
          icon: const Icon(Icons.key),
          label: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar correo de recuperación'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF2A8C82),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => setState(() {
          _showForgotPassword = false;
          _errorMessage = null;
          _successMessage = null;
        }),
        child: const Text(
          'Volver al inicio de sesión',
          style: TextStyle(color: Color(0xFF88F2E8)),
        ),
      ),
    ];
  }
}
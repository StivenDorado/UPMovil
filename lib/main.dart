import 'package:flutter/material.dart';
import 'views/landing.dart'; // Ajusta la ruta si está en otra carpeta

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Propiedades',
      theme: ThemeData(
        primaryColor: const Color(0xFF2A8C82),
        scaffoldBackgroundColor: Colors.white,
        // Puedes configurar más colores y tipografías aquí
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

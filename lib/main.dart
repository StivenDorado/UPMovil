import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'services/firebase.dart';
import 'services/theme_service.dart';

// tus vistas
import 'views/login.dart';
import 'views/landing_page.dart';
import 'views/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer2<AuthProvider, ThemeService>(
        builder: (context, auth, themeService, _) {
          const primaryColor = Color(0xFF275950);
          const accentColor = Color(0xFF88F2E8);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Alquiler App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2A8C82),
                brightness: themeService.isDarkMode ? Brightness.dark : Brightness.light,
                primary: primaryColor,
                secondary: accentColor,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2A8C82),
                brightness: Brightness.dark,
                primary: primaryColor,
                secondary: accentColor,
              ),
              useMaterial3: true,
            ),
            themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            initialRoute: '/',
            routes: {
              '/': (c) {
                // Si ya hay usuario, vamos directo a landing
                if (auth.user != null) {
                  return const LandingPage();
                }
                // Si aún no hemos comprobado el estado de Auth, mostramos splash
                if (!auth.authChecked) {
                  return const SplashScreen();
                }
                // Si no hay usuario y authChecked==true, mostramos login
                return const LoginScreen();
              },
              '/login': (c) => const LoginScreen(),
              '/landing': (c) => const LandingPage(),
              '/profile': (c) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

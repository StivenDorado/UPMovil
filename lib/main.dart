import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'services/firebase.dart';
import 'services/theme_service.dart'; // Import the ThemeService
import 'views/landing_page.dart';
import 'views/login.dart';

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
        ChangeNotifierProvider(
            create: (_) => ThemeService()), // Add ThemeService provider
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Get ThemeService
          return Consumer<ThemeService>(
            builder: (context, themeService, _) {
              // Define color constants
              const primaryColor = Color(0xFF275950);
              const accentColor = Color(0xFF88F2E8);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Alquiler App',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2A8C82),
                    brightness: themeService.isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                    primary: primaryColor,
                    secondary: accentColor,
                  ),
                  // Define AppBar theme to maintain original colors
                  appBarTheme: const AppBarTheme(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  scaffoldBackgroundColor: themeService.isDarkMode
                      ? const Color(0xFF121212)
                      : Colors.grey[50],
                  useMaterial3: true,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF2A8C82),
                    ),
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                    ),
                  ),
                  fontFamily: 'Roboto',
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2A8C82),
                    brightness: Brightness.dark,
                    primary: primaryColor,
                    secondary: accentColor,
                  ),
                  // Define AppBar theme to maintain original colors
                  appBarTheme: const AppBarTheme(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  useMaterial3: true,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF2A8C82),
                    ),
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                    ),
                  ),
                  fontFamily: 'Roboto',
                ),
                themeMode:
                    themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                initialRoute: '/',
                routes: {
                  '/': (context) => authProvider.loading
                      ? const SplashScreen()
                      : authProvider.user != null
                          ? const LandingPage()
                          : const LoginScreen(),
                  '/landing': (context) => const LandingPage(),
                  '/login': (context) => const LoginScreen(),
                },
              );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF88F2E8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

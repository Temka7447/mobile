import 'package:flutter/material.dart';
import 'components/onboarding.dart';
import 'components/login.dart';
import 'components/register.dart';
import 'components/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery App',
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage()
      },
    );
  }
}

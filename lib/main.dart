import 'package:flutter/material.dart';
import 'components/home.dart';
import 'components/login.dart';
import 'components/onboarding.dart';
import 'components/profile.dart';
import 'components/register.dart';
import 'components/forgot_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/forgot_password': (context) => const ForgotPassword(),
      },
    );
  }
}

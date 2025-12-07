import 'package:flutter/material.dart';
import 'package:mobilebiydaalt/components/user/order.dart';
import 'components/user/home.dart';
import 'components/login.dart';
import 'components/user/onboarding.dart';
import 'components/user/profile.dart';
import 'components/register.dart';
import 'components/forgot_password.dart';
import 'components/admin/admin_home.dart';
import 'components/user/order.dart';
import 'components/admin/users.dart';
import 'components/admin/items.dart';

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
        '/admin_home': (context) => const AdminHome(),
        '/order': (context) => const OrderPage(),
        '/users': (context) => const Users(),
        '/items': (context) => const Items()
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Future<bool>? _isLoggedInFuture;
  String userRole = 'user';

  final List<Widget> userPages = const [
    Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _checkLoggedInUser();
  }

  Future<bool> _checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    userRole = prefs.getString('user_role') ?? 'user';

    if (token == null) return false;

    if (userRole == 'admin') {
      if (mounted) Navigator.pushReplacementNamed(context, '/admin_home');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == false) {
          // Not logged in, redirect to login
          Future.microtask(() {
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            automaticallyImplyLeading: false,
          ),
          body: userPages[currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.black12,
            onTap: (index) => setState(() => currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

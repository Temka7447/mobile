import 'package:flutter/material.dart';
import 'onboarding.dart';
import 'login.dart';
import 'register.dart';
import 'order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // Pages shown for each tab
  final List<Widget> pages = const [
    Center(
      child: Text(
        'Welcome to the Home Page!',
        style: TextStyle(fontSize: 24),
      ),
    ),
    LoginPage(),
    RegisterPage(),
    OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Delivery App'),
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange ,
        unselectedItemColor: Colors.black12,
        showSelectedLabels: false,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
=======
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            
            IconButton(
              icon: const Icon(Icons.card_travel),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false, 
      ),

      body: Column(
        children: [
          const SizedBox(height: 20,),

          
        ]
>>>>>>> 694666d0c990e8aa1bc7e03192792ea74da0feaa
      ),
    );
  }
}

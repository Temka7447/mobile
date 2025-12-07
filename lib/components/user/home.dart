import 'package:flutter/material.dart';
import 'onboarding.dart';
import '../login.dart';
import '../register.dart';
import 'order.dart';
import 'profile.dart';

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
    ProfilePage(),
    OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Delivery App'),
      // ),

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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home),
          //   label: 'home',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Admin_home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_rows_rounded),
            label: 'Register',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'order',
          ),
        ],
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.notifications),
        //       onPressed: () {
        //         Navigator.pushReplacementNamed(context, '/');
        //       },
        //     ),
            
        //     IconButton(
        //       icon: const Icon(Icons.card_travel),
        //       onPressed: () {
        //         Navigator.pushReplacementNamed(context, '/');
        //       },
        //     ),
        //   ],
        // ),
        // automaticallyImplyLeading: false, 
      ),

      // body: Column(
      //   children: [
      //     const SizedBox(height: 20,),

          
      //   ]
      // ),
    );
  }
}
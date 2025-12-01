import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
    );
  }
}
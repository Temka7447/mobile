import 'package:flutter/material.dart';
import 'items.dart';
import 'users.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const AdminHomeContent(),  // ← тусад нь хадгалав
    const Items(),
    const Users(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'items'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.table_rows_rounded),
              label: 'users'
          ),
        ],
      ),
    );
  }
}

// 📌 Home Tab UI-г тусад нь салгав
class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                hintText: "Дэлгүүр хайх",
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Дэлгүүр нэмэх'),
                ),
                const SizedBox(width: 16),
              ],
            ),

            const SizedBox(height: 10),

            _storeCard(),
            _storeCard(),
          ],
        ),
      ),
    );
  }

  // 📌 Дэлгүүрийг компонент болгож салгасан
  Widget _storeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 230, 230),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              "images/scooter.png",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Цэцгийн дэлгүүр"),
              Text("16 төрлийн бараа"),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Засах", style: TextStyle(color: Colors.lightBlue)),
              Text("Устгах", style: TextStyle(color: Colors.red)),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
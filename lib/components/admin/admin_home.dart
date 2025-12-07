import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Search Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SearchBar(
                  hintText: "Дэлгүүр хайх",
                ),
              ),

              const SizedBox(height: 20),

              // Add Store Button → Right Side
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
                            borderRadius: BorderRadius.circular(30))),
                    icon: const Icon(Icons.add),
                    label: const Text('Дэлгүүр нэмэх'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              const SizedBox(height: 10),

              // Store Card
              Container(
                width: 330,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 230, 230, 230),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Store Image Rounded
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        "images/store.png", // 👈 өөрийн зургаар солино
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Цэцгийн дэлгүүр",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "16 төрлийн бараа",
                      style: TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            "Засах",
                            style: TextStyle(
                                fontSize: 16, color: Colors.lightBlue),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            "Устгах",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

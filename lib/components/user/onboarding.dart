import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "images/scooter.png",
      "title": "Түргэн шуурхай бэлэг хүргэлт",
      "desc": "Бид таны бэлэг болон хүргэлтийг очиж аваад таны хүссэн газарт хүргэх үйлчилгээ үзүүлнэ",
      "button": "Эхлэх"
    },
    {
      "image": "images/boy1.png",
      "title": "Таны хүссэн бүхнийг, хаана ч хүргэнэ!",
      "desc": "",
      "button": "Үргэлжлүүлэх"
    },
    {
      "image": "images/boy2.png",
      "title": "Дэлгүүр, хоол, бүх хэрэгцээ нэг дор!",
      "desc": "",
      "button": "Үргэлжлүүлэх"
    },
    {
      "image": "images/security.png",
      "title": "Хурдан. Найдвартай. Хямд.",
      "desc": "",
      "button": "Үргэлжлүүлэх"
    },
  ];

  void nextPage() {
    if (currentPage == pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemBuilder: (context, index) {
          final page = pages[index];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(page["image"]!)),
                const SizedBox(height: 16),
                Text(page["title"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(page["desc"] ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(360))),
                  child: Text(page["button"]!),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

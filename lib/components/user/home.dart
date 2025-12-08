import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/store.dart';
import 'items.dart';
import 'profile.dart';
import 'order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<Store> _stores = [];
  bool _isLoading = true;
  final String baseUrl = 'http://localhost:5000';
  String? _selectedShopId;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/shops'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);
        setState(() {
          _stores = jsonResult.map((e) => Store.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print("Failed to load shops: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading shops: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget _getPage() {
    switch (currentIndex) {
      case 0:
        return _shopPage();
      case 1:
        return ProfilePage();
      case 2:
        return OrderPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  Widget _shopPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Дэлгүүрүүд",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stores.isEmpty
                    ? const Center(child: Text("Дэлгүүр байхгүй байна"))
                    : ListView.separated(
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) =>
                            _storeCard(_stores[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _storeCard(Store store) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShopId = store.id;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemsPage(shopId: store.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                blurRadius: 8,
                offset: const Offset(2, 4),
                color: Colors.black.withOpacity(0.15))
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: store.imagePath.isNotEmpty
                    ? Image.network(
                        store.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('images/scooter.png',
                                fit: BoxFit.cover),
                      )
                    : Image.asset('images/scooter.png', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(store.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Text("утас ${store.phone}",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
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
            label: 'home',
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
      ),
    );
  }
}
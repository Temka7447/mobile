import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/store.dart';
import 'order_detail.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Store> _stores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  final String baseUrl = 'http://localhost:5000';

  Future<void> _loadStores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shops'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);
        setState(() {
          _stores = jsonResult.map((e) => Store.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to fetch stores. Status: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Failed to load stores: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f3c9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.notifications_outlined, size: 30),
                  Icon(Icons.shopping_bag_outlined, size: 30),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Дэлгүүрүүд",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Хайх...",
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final store = _stores[index];
                          return storeCard(context: context, store: store);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget storeCard({required BuildContext context, required Store store}) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailPage(
              kind: DetailKind.store,
              title: store.name,
              imagePath: store.imagePath,
              // products: store.products,
            ),
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
              color: Colors.black.withOpacity(0.15),
            )
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
                        // Make sure your backend serves images as static files
                        '$baseUrl/${store.imagePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/default.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/default.png',
                        fit: BoxFit.cover,
                      ),
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
            )
          ],
        ),
      ),
    );
  }
}

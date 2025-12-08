import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemsPage extends StatefulWidget {
  final String shopId;
  const ItemsPage({super.key, required this.shopId});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  final String baseUrl = "http://localhost:5000";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/shops/${widget.shopId}'));
      if (response.statusCode == 200) {
        final shop = json.decode(response.body);
        setState(() {
          products = shop['products'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Бүтээгдэхүүнүүд"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("Бүтээгдэхүүн байхгүй байна."))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: p['imagePath'] != null && p['imagePath'].isNotEmpty
                                  ? Image.network(
                                      p['imagePath'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Image.asset('images/scooter.png', fit: BoxFit.cover),
                                    )
                                  : Image.asset('images/scooter.png', fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Үнэ: ${p['price']}₮"),
                                  Text("Тоо: ${p['quantity']}"),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
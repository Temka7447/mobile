import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/store.dart';
import 'edit_store.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Store> _stores = [];
  bool _isLoading = true;
  final String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

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
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("ERROR LOADING SHOPS: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStore(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/shops/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Дэлгүүр устгагдлаа!")),
        );
        _loadStores();
      } else {
        print("FAILED DELETE ${response.statusCode}");
      }
    } catch (e) {
      print("DELETE ERROR: $e");
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

              // ADD BUTTON
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditStorePage()),
                  ).then((_) => _loadStores());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(360)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Дэлгүүр нэмэх'),
              ),

              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) =>
                            storeCard(_stores[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget storeCard(Store store) {
    return Container(
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
                          Image.asset('images/scooter.png', fit: BoxFit.cover),
                    )
                  : Image.asset('images/scooter.png', fit: BoxFit.cover),
            ),
          ),

          // Name + Phone
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

          // EDIT + DELETE BUTTONS
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStorePage(store: store),
                      ),
                    ).then((_) => _loadStores());
                  },
                  child: const Text(
                    "Засах",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () => _deleteStore(store.id),
                  child: const Text(
                    "Устгах",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

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
  bool _isLoading = false;
  bool _hasMore = true; // To check if more pages are available
  int _page = 0;
  final int _limit = 10;

  final String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    if (!loadMore) _page = 0;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shops?page=$_page&limit=$_limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);
        setState(() {
          if (loadMore) {
            _stores.addAll(jsonResult.map((e) => Store.fromJson(e)).toList());
          } else {
            _stores = jsonResult.map((e) => Store.fromJson(e)).toList();
          }

          _hasMore = jsonResult.length == _limit; // if less than limit, no more pages
          _isLoading = false;
        });
        _page++; // Increment page for next fetch
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
              const Text(
                "Дэлгүүрүүд",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!_isLoading &&
                        _hasMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _loadStores(loadMore: true);
                    }
                    return false;
                  },
                  child: _stores.isEmpty && _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: _stores.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            if (index < _stores.length) {
                              final store = _stores[index];
                              return storeCard(context: context, store: store);
                            } else {
                              // Show loading indicator at the bottom
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== Store Card ==================
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
              shopId: store.id,
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
                child: _buildStoreImage(store),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      store.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    "утас ${store.phone}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================== Image Handling ==================
  Widget _buildStoreImage(Store store) {
    if (store.imagePath != null && store.imagePath.isNotEmpty) {
      final imageUrl = store.imagePath.startsWith('http')
          ? store.imagePath
          : '$baseUrl/${store.imagePath}';
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'images/default.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        'images/default.png',
        fit: BoxFit.cover,
      );
    }
  }
}

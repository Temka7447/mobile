import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/store.dart';
import 'items.dart';
import 'profile.dart';
import 'order.dart';
import 'deliver.dart';
import 'checkout_page.dart';
import 'package:mobilebiydaalt/services/cart_service.dart'; 
import 'my_order_details.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<Store> _stores = [];
  List<dynamic> _deliveries = [];
  bool _isLoadingStores = true;
  bool _isLoadingDeliveries = true;
  final String baseUrl = 'http://localhost:5000';
  String? _selectedShopId;

  final cart = CartService.instance;

  @override
  void initState() {
    super.initState();
    _loadStores();
    _loadDeliveries();
    cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  void _openCheckout() {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сагс хоосон байна')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutPage()));
  }

  Future<void> _loadStores() async {
    setState(() => _isLoadingStores = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/shops'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResult = json.decode(response.body);
        final List<dynamic> list = jsonResult['shops'] ?? [];
        setState(() {
          _stores = list.map((e) => Store.fromJson(Map<String, dynamic>.from(e as Map))).toList();
          _isLoadingStores = false;
        });
      } else {
        setState(() => _isLoadingStores = false);
        // ignore: avoid_print
        print("Failed to load shops: ${response.statusCode}");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error loading shops: $e");
      setState(() => _isLoadingStores = false);
    }
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoadingDeliveries = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/delivery'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResult = json.decode(response.body);
        setState(() {
          _deliveries = (jsonResult['deliveries'] ?? []) as List<dynamic>;
          _isLoadingDeliveries = false;
        });
      } else {
        setState(() => _isLoadingDeliveries = false);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading deliveries: $e');
      setState(() => _isLoadingDeliveries = false);
    }
  }

  // safe address helper based on your Store model (address, latitude, longitude)
  String _getStoreAddress(Store store) {
    final a = (store.address).toString();
    return a.isNotEmpty ? a : '';
  }

  Widget _ordersCarousel(BuildContext context) {
    if (_isLoadingDeliveries) {
      return SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: Colors.orange[700])),
      );
    }

    if (_deliveries.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('Захиалгууд байхгүй', style: TextStyle(color: Colors.grey[700]))),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        primary: false,    // IMPORTANT: don't let this horizontal list become the primary scrollable
        shrinkWrap: true,  // IMPORTANT: allow parent vertical scrolling to control layout
        itemCount: _deliveries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final d = _deliveries[index];
          final imageBase64 = (d['imageBase64'] ?? '').toString();
          Widget avatar;
          if (imageBase64.isNotEmpty) {
            try {
              final bytes = base64Decode(imageBase64);
              avatar = ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(bytes, width: 88, height: 88, fit: BoxFit.cover),
              );
            } catch (_) {
              avatar = Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.image, color: Colors.grey),
              );
            }
          } else {
            avatar = Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.image, color: Colors.grey),
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyOrdersPageDetail(delivery: Map<String, dynamic>.from(d as Map))));
            },
            child: Column(
              children: [
                avatar,
                const SizedBox(height: 6),
                SizedBox(
                  width: 88,
                  child: Text(
                    (d['receiverName'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _shopCard(BuildContext context, Store store) {
    final addr = _getStoreAddress(store);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShopId = store.id;
        });
        Navigator.push(context, MaterialPageRoute(builder: (_) => ItemsPage(shopId: store.id)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(2, 4))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: store.imagePath.isNotEmpty
                    ? Image.network(
                        store.imagePath,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, __, ___) => Image.asset('images/scooter.png', fit: BoxFit.cover),
                      )
                    : Image.asset('images/scooter.png', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(store.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      if (addr.isNotEmpty)
                        Text(addr, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Text("утас ${store.phone}", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 3) {
      _openCheckout();
      return;
    }
    setState(() {
      currentIndex = index;
    });
  }

  Widget _getPage() {
    switch (currentIndex) {
      case 0:
        return _mainScrollView();
      case 1:
        return const DeliveryPage();
      case 2:
        return OrderPage();
      case 4:
        return ProfilePage();
      default:
        return _mainScrollView();
    }
  }

  Widget _mainScrollView() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // allow parent vertical scrolling always
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFFFF8E0),
            padding: const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Захиалгууд', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _ordersCarousel(context),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Дэлгүүрүүд', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _loadStores,
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Хайх...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),

        // Shops list
        SliverPadding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          sliver: _isLoadingStores
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: Colors.orange[700])),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final store = _stores[index];
                    return _shopCard(context, store);
                  }, childCount: _stores.length),
                ),
        ),
      ],
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
        onTap: _onBottomNavTap,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          const BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_outlined), label: 'delivery'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'order'),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 30),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'checkout',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}
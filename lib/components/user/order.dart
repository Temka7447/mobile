import 'package:flutter/material.dart';
import 'package:mobilebiydaalt/models/store.dart';
import 'package:mobilebiydaalt/services/stores_service.dart';
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

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    try {
      final stores = await StoreService.fetchStores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load stores: $e');
      if (!mounted) return;
      setState(() {
        _stores = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дэлгүүрүүдийг татахад алдаа гарлаа: $e')),
      );
    }
  }

  Widget _imageForPath(String imagePath) {
    const placeholder = 'images/scooter.png';

    if (imagePath.isEmpty) {
      return Image.asset(placeholder, fit: BoxFit.cover);
    }

    // Absolute URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) => Image.asset(placeholder, fit: BoxFit.cover),
      );
    }

    // Relative path on backend — use StoreService.baseUrl
    final url = '${StoreService.baseUrl}/${imagePath}'.replaceAll('//', '/').replaceFirst('http:/', 'http://');
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const Center(child: CircularProgressIndicator()),
      errorBuilder: (_, __, ___) => Image.asset(placeholder, fit: BoxFit.cover),
    );
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
                    : RefreshIndicator(
                        onRefresh: _loadStores,
                        child: _stores.isEmpty
                            ? ListView(
                                // allow pull-to-refresh when empty
                                children: [
                                  const SizedBox(height: 60),
                                  const Center(child: Text('Дэлгүүр олдсонгүй')),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: _loadStores,
                                      child: const Text('Дахин ачааллах'),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                itemCount: _stores.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 20),
                                itemBuilder: (context, index) {
                                  final store = _stores[index];
                                  return storeCard(context: context, store: store);
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: _imageForPath(store.imagePath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        // show address if available (location.address)
                        if (store.address.isNotEmpty)
                          Text(
                            store.address,
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("утас ${store.phone}", style: const TextStyle(fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobilebiydaalt/models/store.dart';
import '../../services/admins_service.dart';
import 'edit_store.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
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
      final stores = await AdminService.fetchStores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print("ERROR LOADING SHOPS: $e");
      if (!mounted) return;
      setState(() {
        _stores = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дэлгүүрүүдийг татахдаа алдаа гарлаа: $e')),
      );
    }
  }

  Future<void> _deleteStore(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Устгах'),
        content: const Text('Энэ дэлгүүрийг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Болих')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Устгах')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await AdminService.deleteStore(id);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Дэлгүүр устгагдлаа!")),
        );
        await _loadStores();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Дэлгүүр устгахад алдаа гарлаа")),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("DELETE ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Устгах үед алдаа гарлаа: $e')),
      );
    }
  }

  Widget _imageWidget(Store store) {
    const placeholder = 'images/scooter.png';
    final path = store.imagePath;
    if (path.isEmpty) return Image.asset(placeholder, fit: BoxFit.cover);

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(placeholder, fit: BoxFit.cover),
      );
    } else {
      final url = '${AdminService.baseUrl}/${path}'.replaceAll('//', '/').replaceFirst('http:/', 'http://');
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(placeholder, fit: BoxFit.cover),
      );
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
                    : _stores.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Дэлгүүр олдсонгүй'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadStores,
                                  child: const Text('Дахин ачааллах'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _stores.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) =>
                                _storeCard(_stores[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeCard(Store store) {
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
              child: _imageWidget(store),
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
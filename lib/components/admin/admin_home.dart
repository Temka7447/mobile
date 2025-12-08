import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilebiydaalt/models/store.dart';
import 'package:mobilebiydaalt/services/admins_service.dart'; // <- ensure this matches your filename
import 'edit_store.dart';
import 'workers.dart';
import 'items.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Store> _stores = [];
  bool _isLoading = true;
  int currentIndex = 0;
  String? _selectedShopId;

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
      if (!mounted) return;
      setState(() {
        _stores = [];
        _isLoading = false;
      });
      // show error to the user
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Устгах үед алдаа гарлаа: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Гарах'),
        content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Болих')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Гарах')),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_phone');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _getPage() {
    switch (currentIndex) {
      case 0:
        return _shopPage();
      case 1:
        return _selectedShopId != null
            ? ItemsAdmin(shopId: _selectedShopId!)
            : const Center(child: Text("Дэлгүүрээ сонгоно уу"));
      case 2:
        return const WorkersAdmin();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f3c9),
      appBar: AppBar(
        backgroundColor: const Color(0xfff7f3c9),
        elevation: 0,
        title: const Text('Админ самбар', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _loadStores,
            tooltip: 'Дахин ачааллах',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orange),
            onPressed: _logout,
            tooltip: 'Гарах',
          ),
        ],
      ),
      body: SafeArea(child: _getPage()),
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
            icon: Icon(Icons.other_houses_outlined),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_4_outlined),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  Widget _shopPage() {
    return Padding(
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
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
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
          currentIndex = 1; // go to Items tab
        });
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
                    ? _imageWidget(store)
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
            Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 15),
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
      ),
    );
  }

  Widget _imageWidget(Store store) {
    const placeholder = 'images/scooter.png';
    final path = store.imagePath;
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
}
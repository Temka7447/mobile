import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilebiydaalt/models/product.dart';
import 'package:mobilebiydaalt/services/product_service.dart';
import 'package:mobilebiydaalt/services/cart_service.dart';
import '../user/checkout_page.dart';

enum DetailKind { order, store }

class DetailPage extends StatefulWidget {
  final DetailKind kind;
  final String title;
  final String? imagePath;
  final Widget? imageWidget;
  final String? shopId;

  const DetailPage({
    super.key,
    required this.kind,
    required this.title,
    this.imagePath,
    this.imageWidget,
    this.shopId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Product> _products = [];
  final Map<int, int> _selected = {};
  bool _loading = true;

  static const double _bottomBarHeight = 64.0;
  final NumberFormat _fmt = NumberFormat('#,##0', 'en_US');
  final cart = CartService.instance;

  int get _total {
    int sum = 0;
    _selected.forEach((index, qty) {
      if (index >= 0 && index < _products.length) {
        final productPrice = _products[index].price;
        final priceInt = (productPrice is num) ? (productPrice as num).toInt() : int.tryParse(productPrice.toString()) ?? 0;
        sum += priceInt * qty;
      }
    });
    return sum;
  }

  @override
  void initState() {
    super.initState();
    if (widget.shopId != null) {
      _fetchProducts(widget.shopId!);
    } else {
      _loading = false;
    }
    cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  Future<void> _fetchProducts(String shopId) async {
    setState(() => _loading = true);
    try {
      final products = await ProductService.fetchProducts(shopId);
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Бүтээгдэхүүн авахад алдаа гарлаа: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _networkOrAsset(String imagePath, {BoxFit fit = BoxFit.cover, double? height}) {
    const placeholder = 'images/scooter.png';

    if (imagePath.isEmpty) {
      return Image.asset(placeholder, height: height, fit: fit);
    }

    final url = (imagePath.startsWith('http://') || imagePath.startsWith('https://'))
        ? imagePath
        : '${ProductService.baseUrl}/${imagePath}'.replaceAll('//', '/').replaceFirst('http:/', 'http://');

    return Image.network(
      url,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) => Image.asset(placeholder, height: height, fit: fit),
    );
  }

  Widget _buildProductImage(Product p) {
    if (p.imagePath.isNotEmpty) {
      return _networkOrAsset(p.imagePath);
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }

  Widget _buildShopImage() {
    if (widget.imageWidget != null) return widget.imageWidget!;
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      final ip = widget.imagePath!;
      if (ip.startsWith('http://') || ip.startsWith('https://')) {
        return Image.network(ip, height: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
      } else {
        return Image.asset(ip, height: 160, fit: BoxFit.cover);
      }
    }
    return const SizedBox.shrink();
  }

  void _increment(int index) {
    if (index < 0 || index >= _products.length) return;
    final selectedQty = _selected[index] ?? 0;
    final availableQty = _products[index].quantity;
    if (selectedQty < availableQty) {
      if (!mounted) return;
      setState(() {
        _selected[index] = selectedQty + 1;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Үлдэгдэл хүрэлцэхгүй'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _decrement(int index) {
    if (index < 0 || index >= _products.length) return;
    final selectedQty = _selected[index] ?? 0;
    if (selectedQty > 0) {
      if (!mounted) return;
      setState(() {
        final newQty = selectedQty - 1;
        if (newQty > 0) {
          _selected[index] = newQty;
        } else {
          _selected.remove(index);
        }
      });
    }
  }

  void _addSelectedToCart() {
    if (_selected.isEmpty) return;
    for (final entry in _selected.entries) {
      final idx = entry.key;
      final qty = entry.value;
      if (idx >= 0 && idx < _products.length && qty > 0) {
        final product = _products[idx];
        final toAdd = qty.clamp(0, product.quantity);
        if (toAdd > 0) {
          cart.addItem(product, toAdd);
        }
      }
    }
    setState(() => _selected.clear());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сагсанд нэмэгдлээ')));
  }

  void _goToCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOrder = widget.kind == DetailKind.order;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isOrder ? Colors.orange : Colors.deepPurple,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: _goToCheckout, 
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _products.isEmpty
          ? const Center(child: Text("Бүтээгдэхүүн байхгүй байна"))
          : Column(
              children: [
                if (widget.imageWidget != null || widget.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(borderRadius: BorderRadius.circular(18), child: _buildShopImage()),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: _bottomBarHeight + 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, idx) {
                      final p = _products[idx];
                      final qty = _selected[idx] ?? 0;
                      final selected = qty > 0;

                      return GestureDetector(
                        onTap: () => _increment(idx),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(2, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: _buildProductImage(p),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  p.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${_fmt.format((p.price is num) ? (p.price as num) : num.tryParse(p.price.toString()) ?? 0)}₮',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: selected ? Colors.orange : Colors.black87,
                                            ),
                                          ),
                                          if (selected)
                                            TextSpan(
                                              text: ' × $qty',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text('Бэлэн: ${p.quantity}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (selected)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(onPressed: () => _decrement(idx), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
                                        Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(onPressed: () => _increment(idx), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        height: _bottomBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Нийт тооцоо  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    TextSpan(text: '${_fmt.format(_total)} ₮', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _total > 0 ? _addSelectedToCart : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              child: const Text('Сагсанд нэмэх'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _total >= 0
                  ? () {
                      _goToCheckout();
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios,),
            ),
          ],
        ),
      ),
    );
  }
}
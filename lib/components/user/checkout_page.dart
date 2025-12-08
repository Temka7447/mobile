import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilebiydaalt/services/cart_service.dart';
import 'package:mobilebiydaalt/models/product.dart';

/// CheckoutPage shows a scrollable list of items coming from:
///  - the global CartService (cart items)
///  - optionally a list of chosen items passed in `chosen`
/// It merges both sources for display and allows local +/- adjustments.
/// If an item exists in the global cart, quantity changes are synced to the global cart.
class CheckoutPage extends StatefulWidget {
  /// Optional chosen items (e.g. pass from DetailPage selection).
  /// Use CartItem objects (product + quantity).
  final List<CartItem>? chosen;

  const CheckoutPage({super.key, this.chosen});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cart = CartService.instance;
  final NumberFormat _fmt = NumberFormat('#,##0', 'en_US');

  // Local merged map of productId -> CartItem used for UI and checkout calculations.
  final Map<String, CartItem> _displayMap = {};

  // Snapshot of which ids were originally present in global cart
  final Set<String> _originalCartIds = {};

  @override
  void initState() {
    super.initState();
    cart.addListener(_onGlobalCartChanged);
    _buildDisplayFromSources();
  }

  @override
  void dispose() {
    cart.removeListener(_onGlobalCartChanged);
    super.dispose();
  }

  void _onGlobalCartChanged() {
    // Rebuild display from both sources so UI stays consistent if global cart changed elsewhere.
    _buildDisplayFromSources();
  }

  void _buildDisplayFromSources() {
    _displayMap.clear();
    _originalCartIds.clear();

    // 1) Add items from global cart
    for (final it in cart.items) {
      _displayMap[it.product.id] = CartItem(product: it.product, quantity: it.quantity);
      _originalCartIds.add(it.product.id);
    }

    // 2) Merge chosen items (passed via constructor)
    if (widget.chosen != null) {
      for (final chosenItem in widget.chosen!) {
        final id = chosenItem.product.id;
        if (_displayMap.containsKey(id)) {
          // sum quantities but do not exceed available stock
          final existing = _displayMap[id]!;
          final newQty = (existing.quantity + chosenItem.quantity).clamp(0, chosenItem.product.quantity);
          existing.quantity = newQty;
        } else {
          // clone to avoid mutating caller objects
          final clone = CartItem(
            product: Product(
              id: chosenItem.product.id,
              name: chosenItem.product.name,
              price: chosenItem.product.price,
              imagePath: chosenItem.product.imagePath,
              quantity: chosenItem.product.quantity,
            ),
            quantity: chosenItem.quantity.clamp(0, chosenItem.product.quantity),
          );
          _displayMap[id] = clone;
        }
      }
    }

    if (mounted) setState(() {});
  }

  List<CartItem> get _displayItems => _displayMap.values.toList(growable: false);

  num get _totalPrice {
    num sum = 0;
    for (final it in _displayItems) {
      sum += it.lineTotal;
    }
    return sum;
  }

  void _incrementLocal(CartItem item) {
    final p = item.product;
    final newQty = (item.quantity + 1).clamp(0, p.quantity);
    if (newQty == item.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Үлдэгдэл хүрэлцэхгүй')));
      return;
    }
    // If originally in global cart, update global cart too
    if (_originalCartIds.contains(p.id)) {
      cart.updateQuantity(p.id, newQty);
    } else {
      item.quantity = newQty;
      setState(() {});
    }
  }

  void _decrementLocal(CartItem item) {
    final p = item.product;
    final newQty = (item.quantity - 1).clamp(0, p.quantity);
    if (_originalCartIds.contains(p.id)) {
      if (newQty <= 0) {
        cart.removeItem(p.id);
      } else {
        cart.updateQuantity(p.id, newQty);
      }
    } else {
      if (newQty <= 0) {
        _displayMap.remove(p.id);
      } else {
        item.quantity = newQty;
      }
      setState(() {});
    }
  }

  void _removeLocal(CartItem item) {
    final p = item.product;
    if (_originalCartIds.contains(p.id)) {
      cart.removeItem(p.id);
    }
    _displayMap.remove(p.id);
    setState(() {});
  }

  Widget _buildCard(CartItem item) {
    final Product p = item.product;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(2, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: p.imagePath.isNotEmpty
                ? Image.network(p.imagePath, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)))
                : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('${_fmt.format(p.price)} ₮', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Үлдэгдэл: ${p.quantity}'),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => _incrementLocal(item),
              ),
              Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => _decrementLocal(item),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeLocal(item),
            tooltip: 'Устгах',
          ),
        ],
      ),
    );
  }

  Future<void> _onCheckoutPressed() async {
    if (_displayItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сагс хоосон байна')));
      return;
    }

    // Here you would send the order to your backend using the _displayItems data.
    // For now, show a confirmation and clear the global cart for purchased items.
    final total = _totalPrice;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Захиалга амжилттай илгээгдлээ: ${_fmt.format(total)} ₮')));

    // Clear global cart (simple approach). If you prefer to remove only purchased quantities,
    // iterate originalCartIds and remove/update accordingly.
    cart.clear();

    // Close checkout page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сагс / Төлбөр'),
        backgroundColor: const Color(0xfff7f3c9),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xfff7f3c9),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Сагс хоосон'),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Буцах')),
                  ],
                ),
              )
            : Column(
                children: [
                  // Expanded scrollable list of cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _buildCard(items[i]),
                    ),
                  ),

                  // Total + Checkout button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Нийт: ${_fmt.format(_totalPrice)} ₮',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _onCheckoutPressed,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Захиалах'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }
}
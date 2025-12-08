import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mobilebiydaalt/services/cart_service.dart';
import 'package:mobilebiydaalt/models/product.dart';
import '../user/deliver.dart'; // navigate to DeliveryPage

class CheckoutPage extends StatefulWidget {
  /// Optional chosen items (e.g. pass from DetailPage selection).
  final List<CartItem>? chosen;

  /// Optional store location passed from DetailPage (Map with keys: address, lat, lng)
  final Map<String, dynamic>? storeLocation;

  const CheckoutPage({super.key, this.chosen, this.storeLocation});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cart = CartService.instance;
  final NumberFormat _fmt = NumberFormat('#,##0', 'en_US');

  final Map<String, CartItem> _displayMap = {};
  final Set<String> _originalCartIds = {};

  // adjust to your server base url if needed
  static const String _baseUrl = 'http://localhost:5000';

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

  void _onGlobalCartChanged() => _buildDisplayFromSources();

  void _buildDisplayFromSources() {
    _displayMap.clear();
    _originalCartIds.clear();

    for (final it in cart.items) {
      _displayMap[it.product.id] = CartItem(product: it.product, quantity: it.quantity);
      _originalCartIds.add(it.product.id);
    }

    if (widget.chosen != null) {
      for (final chosenItem in widget.chosen!) {
        final id = chosenItem.product.id;
        if (_displayMap.containsKey(id)) {
          final existing = _displayMap[id]!;
          final newQty = (existing.quantity + chosenItem.quantity).clamp(0, chosenItem.product.quantity);
          existing.quantity = newQty;
        } else {
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

  /// Send order to backend and, on success, subtract ordered quantities from local product quantities
  /// and update the global cart accordingly.
  Future<void> _onCheckoutPressed() async {
    final items = _displayItems;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сагс хоосон байна')));
      return;
    }

    // Build payload expected by your /delivery endpoint
    final payloadItems = items.map((ci) => {
          'productId': ci.product.id,
          'name': ci.product.name,
          'price': ci.product.price,
          'quantity': ci.quantity,
        }).toList();

    final payload = {
      'items': payloadItems,
      'orderTotal': _totalPrice,
      'storeLocation': widget.storeLocation ?? {},
      'createdAt': DateTime.now().toIso8601String(),
      // you can add pickup/deliver/receiver fields here if you have them
    };

    try {
      final uri = Uri.parse('$_baseUrl/delivery');
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // success: update local product quantities and global cart
        for (final ci in items) {
          final pid = ci.product.id;
          final purchased = ci.quantity;

          // 1) update local displayed product quantity
          final display = _displayMap[pid];
          if (display != null) {
            // Product model may be immutable or have final fields.
            // Instead of mutating display.product.quantity directly (which can cause errors),
            // create a new Product instance with updated quantity and replace the CartItem entry.
            final currentProduct = display.product;
            final currentQty = (currentProduct.quantity ?? 0);
            final updatedQty = (currentQty - purchased) >= 0 ? (currentQty - purchased) : 0;

            final updatedProduct = Product(
              id: currentProduct.id,
              name: currentProduct.name,
              price: currentProduct.price,
              imagePath: currentProduct.imagePath,
              quantity: updatedQty,
            );

            // preserve the CartItem.quantity (how many user has chosen) but if you want to reset it, adjust accordingly
            final newCartItem = CartItem(product: updatedProduct, quantity: display.quantity);
            _displayMap[pid] = newCartItem;
          }

          // 2) update global cart: reduce or remove
          try {
            final global = cart.items.firstWhere((c) => c.product.id == pid);
            final newQty = global.quantity - purchased;
            if (newQty <= 0) {
              cart.removeItem(pid);
            } else {
              cart.updateQuantity(pid, newQty);
            }
          } catch (e) {
            // not in global cart — maybe it was a chosen-only item; ignore
          }
        }

        if (mounted) setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Захиалга амжилттай илгээгдлээ')));

        // Navigate to DeliveryPage so user can fill delivery details.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeliveryPage(
              orderItems: items,
              orderTotal: _totalPrice,
              storeLocation: widget.storeLocation,
            ),
          ),
        );
      } else {
        // server returned an error
        final body = resp.body.isNotEmpty ? resp.body : 'server error';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Захиалга амжилтгүй боллоо: $body')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Сүлжээний алдаа: $e')));
    }
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _buildCard(items[i]),
                    ),
                  ),
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
                          child: const Text('Захиалга өгөх'),
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
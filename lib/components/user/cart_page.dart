import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilebiydaalt/services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartService.instance;
  final formatter = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = cart.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сагс'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Сагс хоосон'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      return ListTile(
                        leading: it.product.imagePath.isNotEmpty
                            ? Image.network(it.product.imagePath, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                            : const Icon(Icons.image),
                        title: Text(it.product.name),
                        subtitle: Text('${formatter.format(it.product.price)} ₮ × ${it.quantity} = ${formatter.format(it.lineTotal)} ₮'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () {
                                final newQty = it.quantity - 1;
                                cart.updateQuantity(it.product.id, newQty);
                              },
                            ),
                            Text('${it.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                final newQty = it.quantity + 1;
                                // Optionally enforce available stock limit: it.product.quantity
                                if (it.product.quantity != null && newQty > it.product.quantity) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Үлдэгдэл хүрэлцэхгүй')));
                                  return;
                                }
                                cart.updateQuantity(it.product.id, newQty);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => cart.removeItem(it.product.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Нийт: ${formatter.format(cart.totalPrice)} ₮',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () {
                                // TODO: implement checkout flow (send order to server)
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Захиалга: ${formatter.format(cart.totalPrice)} ₮ илгээх')));
                                // For demo, clear cart after "checkout"
                                cart.clear();
                                Navigator.of(context).pop();
                              },
                        child: const Text('Захиалах'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
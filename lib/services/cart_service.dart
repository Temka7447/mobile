import 'package:flutter/foundation.dart';
import 'package:mobilebiydaalt/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  num get lineTotal => (product.price) * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}

/// Simple singleton cart service that notifies listeners on changes.
/// Not persisted to disk — you can extend this to use SharedPreferences or a DB.
class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get totalItems {
    var sum = 0;
    for (final it in _items.values) {
      sum += it.quantity;
    }
    return sum;
  }

  num get totalPrice {
    num sum = 0;
    for (final it in _items.values) {
      sum += it.lineTotal;
    }
    return sum;
  }

  void addItem(Product p, int qty) {
    if (qty <= 0) return;
    final key = p.id;
    if (_items.containsKey(key)) {
      _items[key]!.quantity += qty;
    } else {
      // clone product to avoid accidental external mutation
      final cloned = Product(
        id: p.id,
        name: p.name,
        price: p.price,
        imagePath: p.imagePath,
        quantity: p.quantity,
      );
      _items[key] = CartItem(product: cloned, quantity: qty);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (!_items.containsKey(productId)) return;
    if (qty <= 0) {
      _items.remove(productId);
    } else {
      _items[productId]!.quantity = qty;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
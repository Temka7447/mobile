import 'product.dart';

class Store {
  final String name;
  final String phone;
  final String imagePath;
  final List<Product> products;

  Store({
    required this.name,
    required this.phone,
    required this.imagePath,
    required this.products,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];
    final products = productsJson.map((e) => Product.fromJson(e)).toList();

    return Store(
      name: json['name'] ?? 'Unnamed Store',
      phone: json['phone'] ?? '',
      imagePath: json['imagePath'] ?? 'images/default.png',
      products: products,
    );
  }
}

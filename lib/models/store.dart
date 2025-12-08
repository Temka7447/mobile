import 'product.dart';

class Store {
  final String id;
  final String name;
  final String phone;
  final String imagePath;
  final List<Product> products;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.imagePath,
    required this.products,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      imagePath: json['imagePath'] ?? '',
      products: json['products'] != null
          ? (json['products'] as List)
              .map((p) => Product.fromJson(p))
              .toList()
          : [],
    );
  }
}
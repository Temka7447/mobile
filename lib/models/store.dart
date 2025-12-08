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
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      products: (json['products'] as List?)
              ?.where((p) => p != null)
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

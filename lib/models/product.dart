class Product {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null ? json['price'] as int : 0,
      imagePath: json['imagePath'] ?? 'images/default.png',
      quantity: json['quantity'] != null ? json['quantity'] as int : 0,
    );
  }
}

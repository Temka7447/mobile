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
      price: json['price'] ?? 0,
      imagePath: json['imagePath'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

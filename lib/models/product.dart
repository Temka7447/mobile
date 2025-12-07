class Product {
  final String name;
  final int price;
  final String imagePath;
  final int quantity; // stock left

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      imagePath: json['imagePath'] ?? 'images/default.png',
      quantity: json['quantity'] ?? 0, // default 0 if missing
    );
  }
}

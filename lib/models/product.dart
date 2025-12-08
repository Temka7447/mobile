class Product {
  final String name;
  final int price;
  final String imagePath;
  final int quantity;
  final String? shopName;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
    this.shopName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      imagePath: json['imagePath'] != null
          ? json['imagePath'].toString()
          : '', // if your server returns local path, we will prepend base URL later
      quantity: json['quantity'] ?? 0,
      shopName: json['shopName'],
    );
  }

  String get fullImagePath {
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://localhost:5000/$imagePath'; // prepend backend URL
  }
}

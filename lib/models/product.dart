class Product {
  final String id;
  final String name;
  final num price;
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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? 0) as num,
      imagePath: (json['imagePath'] ?? json['image'] ?? '').toString(),
      quantity: (json['quantity'] ?? 0) is int
          ? (json['quantity'] as int)
          : (json['quantity'] != null ? (json['quantity'] as num).toInt() : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
    };
  }
}
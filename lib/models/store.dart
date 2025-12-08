import 'product.dart';

class Store {
  final String id;
  final String name;
  final String phone;
  final String imagePath;
  final List<Product> products;

  // New location fields
  final String address;
  final double? latitude;
  final double? longitude;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.imagePath,
    required this.products,
    this.address = '',
    this.latitude,
    this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    // Parse products safely
    final rawProducts = json['products'];
    List<Product> parsedProducts = [];
    if (rawProducts is List) {
      parsedProducts = rawProducts
          .where((p) => p != null)
          .map((p) => Product.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    // Location may be nested under 'location' or provided as flat fields
    String address = '';
    double? lat;
    double? lng;

    final loc = json['location'];
    if (loc is Map) {
      address = (loc['address'] ?? '')?.toString() ?? '';
      if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
      if (loc['lng'] != null) lng = (loc['lng'] as num).toDouble();
    } else {
      // fallback to flat fields
      address = (json['address'] ?? '')?.toString() ?? '';
      if (json['lat'] != null) lat = (json['lat'] as num).toDouble();
      if (json['lng'] != null) lng = (json['lng'] as num).toDouble();
    }

    return Store(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? json['image'] ?? '').toString(),
      products: parsedProducts,
      address: address,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'imagePath': imagePath,
      'products': products.map((p) => p.toJson()).toList(),
      'location': {
        'address': address,
        'lat': latitude,
        'lng': longitude,
      },
    };
  }
}
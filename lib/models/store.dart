class Store {
  final String id;
  final String name;
  final String phone;
  final String imagePath;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.imagePath,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] ?? '', // default to empty string
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      imagePath: json['imagePath'] ?? 'images/default.png',
    );
  }
}

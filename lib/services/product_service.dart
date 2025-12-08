import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // Use 10.0.2.2 for Android emulator. Replace with your machine IP for real device.
  static const String baseUrl = 'http://localhost:5000';

  /// Fetch products for a shop.
  /// Accepts server responses of either:
  /// - plain List: [ {...}, {...} ]
  /// - object wrapper: { "products": [ ... ] } or { "data": [ ... ] }
  /// - or any map that contains a List value
  /// Throws an Exception when the payload can't be parsed or request fails.
  static Future<List<Product>> fetchProducts(String shopId) async {
    final uri = Uri.parse('$baseUrl/shops/$shopId/products');
    final response = await http.get(uri);

    // Debug print to help diagnose payload issues during development.
    // Remove in production.
    // ignore: avoid_print
    print('GET $uri -> ${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load products. Status: ${response.statusCode}');
    }

    final dynamic decoded = json.decode(response.body);
    List<dynamic>? rawList;

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      // common keys
      if (decoded['products'] is List) {
        rawList = decoded['products'] as List<dynamic>;
      } else if (decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        // find the first List value in the map
        for (final v in decoded.values) {
          if (v is List) {
            rawList = v as List<dynamic>;
            break;
          }
        }
      }
    }

    if (rawList == null) {
      throw Exception('Unexpected payload for /shops/$shopId/products: not a List nor contains one.');
    }

    final parsed = <Product>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        parsed.add(Product.fromJson(item));
      } else if (item is Map) {
        parsed.add(Product.fromJson(Map<String, dynamic>.from(item)));
      } else {
        // skip unexpected items
        // ignore: avoid_print
        print('Skipping non-map item in products list: ${item.runtimeType}');
      }
    }

    return parsed;
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../services/admins_service.dart';
import 'package:mobilebiydaalt/models/product.dart';

class ProductService {
  // Use AdminService.baseUrl so emulator/device host selection stays consistent
  static String get baseUrl => AdminService.baseUrl;

  /// Fetch products for a shop.
  /// Tries:
  /// 1) GET /shops/:shopId and read `products` from the returned shop object
  /// 2) fallback to GET /shops/:shopId/products if the first endpoint doesn't return products
  static Future<List<Product>> fetchProducts(String shopId, {Duration timeout = const Duration(seconds: 10)}) async {
    final uriShop = Uri.parse('$baseUrl/shops/$shopId');
    final uriProducts = Uri.parse('$baseUrl/shops/$shopId/products');

    try {
      final resp = await http.get(uriShop).timeout(timeout);
      // ignore: avoid_print
      print('GET $uriShop -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode == 200) {
        final decoded = _decodeJsonSafe(resp.body);
        // If decoded is a map and contains products, parse them
        if (decoded is Map<String, dynamic>) {
          // server might wrap under { shop: {...} } or return the shop directly
          Map<String, dynamic>? shopMap;
          if (decoded['shop'] is Map) {
            shopMap = Map<String, dynamic>.from(decoded['shop'] as Map);
          } else if (decoded.containsKey('products') || decoded.containsKey('name')) {
            shopMap = Map<String, dynamic>.from(decoded);
          } else if (decoded['success'] == true && decoded['shops'] is List) {
            // unlikely here, continue to fallback
            shopMap = null;
          }

          if (shopMap != null && shopMap['products'] is List) {
            return _parseProductList(shopMap['products'] as List<dynamic>);
          }

          // maybe the endpoint returned the shop object nested in a wrapper
          for (final v in decoded.values) {
            if (v is Map && v['products'] is List) {
              return _parseProductList(v['products'] as List<dynamic>);
            }
          }
        }

        // If we reach here, first endpoint did not yield products -> try fallback
      } else {
        // non-200 from shop endpoint -> try fallback before failing
        // ignore: avoid_print
        print('Shop endpoint returned ${resp.statusCode}, trying /products fallback');
      }

      // Fallback endpoint: GET /shops/:shopId/products
      final resp2 = await http.get(uriProducts).timeout(timeout);
      // ignore: avoid_print
      print('GET $uriProducts -> ${resp2.statusCode}: ${resp2.body}');

      if (resp2.statusCode != 200) {
        throw Exception('Failed to load products: ${resp2.statusCode}');
      }

      final decoded2 = _decodeJsonSafe(resp2.body);
      if (decoded2 is List) {
        return _parseProductList(decoded2);
      } else if (decoded2 is Map && decoded2['products'] is List) {
        return _parseProductList(decoded2['products'] as List<dynamic>);
      } else {
        // find first List in the map
        if (decoded2 is Map) {
          for (final v in decoded2.values) {
            if (v is List) return _parseProductList(v);
          }
        }
      }

      throw Exception('Unexpected payload for products');
    } on SocketException {
      throw Exception('Could not connect to server. Check network / server status.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be unreachable.');
    }
  }

  static dynamic _decodeJsonSafe(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (fe) {
      final snippet = body.length > 500 ? body.substring(0, 500) + '…' : body;
      throw Exception('Failed to parse JSON from server: ${fe.message}. Body: $snippet');
    }
  }

  static List<Product> _parseProductList(List<dynamic> raw) {
    final parsed = <Product>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        parsed.add(Product.fromJson(item));
      } else if (item is Map) {
        parsed.add(Product.fromJson(Map<String, dynamic>.from(item)));
      } else {
        // ignore non-map
        // ignore: avoid_print
        print('Skipping non-map product item: ${item.runtimeType}');
      }
    }
    return parsed;
  }
}
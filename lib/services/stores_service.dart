import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobilebiydaalt/models/store.dart';

class StoreService {
  // Public so UI code can reference StoreService.baseUrl when building image URLs.
  // Use 10.0.2.2 for Android emulator. Replace with your machine LAN IP for a real device.
  static const String baseUrl = 'http://localhost:5000';

  /// Fetch shops/stores safely.
  /// Accepts server responses of either:
  /// - a plain List: [ {...}, {...} ]
  /// - an object wrapper: { "shops": [ ... ] } or { "data": [ ... ] }
  /// - any map that contains a List value
  static Future<List<Store>> fetchStores() async {
    final uri = Uri.parse('$baseUrl/shops');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    // Debug: keep this during development to see exact server payload.
    // ignore: avoid_print
    print('GET $uri -> ${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch stores. Status: ${response.statusCode}');
    }

    final dynamic decoded = json.decode(response.body);
    List<dynamic>? rawList;

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['shops'] is List) {
        rawList = decoded['shops'] as List<dynamic>;
      } else if (decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        // find first List value in the map
        for (final v in decoded.values) {
          if (v is List) {
            rawList = v as List<dynamic>;
            break;
          }
        }
      }
    }

    if (rawList == null) {
      throw Exception('Unexpected payload for /shops: not a List nor contains one.');
    }

    final parsed = <Store>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        parsed.add(Store.fromJson(item));
      } else if (item is Map) {
        parsed.add(Store.fromJson(Map<String, dynamic>.from(item)));
      } else {
      
        print('Skipping non-map item in shops list: ${item.runtimeType}');
      }
    }

    return parsed;
  }
}
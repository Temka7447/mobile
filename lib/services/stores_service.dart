import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import 'package:mobilebiydaalt/models/store.dart';

class StoreService {
  // Public so UI code can reference StoreService.baseUrl when building image URLs.
  // Use 10.0.2.2 for Android emulator. Replace with your machine LAN IP for a real device.
  static const String baseUrl = 'http://localhost:5000';

  /// Fetch shops/stores safely.
  static Future<List<Store>> fetchStores({Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/shops');
    try {
      final response = await http.get(uri).timeout(timeout, onTimeout: () => throw TimeoutException('Request timed out'));
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
          // ignore non-map items
          // ignore: avoid_print
          print('Skipping non-map item in shops list: ${item.runtimeType}');
        }
      }

      return parsed;
    } on SocketException {
      throw Exception('Could not connect to server. Check network / server status.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be unreachable.');
    }
  }

  /// Create a new store. Sends 'location' nested object when provided via Store.toJson().
  /// Returns the created Store.
  static Future<Store> createStore(Store store, {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/shops');
    final payload = store.toJson();
    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timed out'));
      // ignore: avoid_print
      print('POST $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 201 && resp.statusCode != 200) {
        throw Exception('Failed to create store. Status: ${resp.statusCode} Body: ${resp.body}');
      }

      final decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return Store.fromJson(decoded);
      } else {
        // If server returned wrapper object, try to find shop inside
        if (decoded is Map) {
          for (final v in decoded.values) {
            if (v is Map && (v['_id'] != null || v['name'] != null)) {
              return Store.fromJson(Map<String, dynamic>.from(v));
            }
          }
        }
        throw Exception('Unexpected response when creating store.');
      }
    } on SocketException {
      throw Exception('Could not connect to server. Check network / server status.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be unreachable.');
    }
  }

  /// Update an existing store; sends nested 'location' object if present in store.toJson().
  static Future<Store> updateStore(String id, Store store, {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    final payload = store.toJson();
    try {
      final resp = await http
          .put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timed out'));
      // ignore: avoid_print
      print('PUT $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('Failed to update store. Status: ${resp.statusCode} Body: ${resp.body}');
      }

      final decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return Store.fromJson(decoded);
      } else {
        // try to find a shop-like object in wrapper
        if (decoded is Map) {
          for (final v in decoded.values) {
            if (v is Map && (v['_id'] != null || v['name'] != null)) {
              return Store.fromJson(Map<String, dynamic>.from(v));
            }
          }
        }
        throw Exception('Unexpected response when updating store.');
      }
    } on SocketException {
      throw Exception('Could not connect to server. Check network / server status.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be unreachable.');
    }
  }

  /// Delete store by id.
  static Future<bool> deleteStore(String id, {Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    try {
      final resp = await http.delete(uri).timeout(timeout, onTimeout: () => throw TimeoutException('Request timed out'));
      // ignore: avoid_print
      print('DELETE $uri -> ${resp.statusCode}: ${resp.body}');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } on SocketException {
      throw Exception('Could not connect to server. Check network / server status.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be unreachable.');
    }
  }
}
import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform, SocketException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilebiydaalt/models/store.dart';

class AdminService {
  // If you need to test on a physical device, set this to your machine IP:
  // static const String _deviceHost = 'http://192.168.1.42:5000';
  static const String _deviceHost = '';

  // baseUrl automatically chooses the correct host for emulator/simulator/web
  static String get baseUrl {
    if (_deviceHost.isNotEmpty) return _deviceHost;
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  // Get auth headers (include JWT if present)
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Fetch stores (handles plain list or common wrapper shapes).
  /// Throws Exception with a friendly message on failure.
  static Future<List<Store>> fetchStores({Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/shops');
    final headers = await _headers();

    try {
      final resp = await http.get(uri, headers: headers).timeout(timeout);
      // ignore: avoid_print
      print('GET $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('Failed to fetch stores (status ${resp.statusCode})');
      }

      final dynamic decoded = jsonDecode(resp.body);
      List<dynamic>? rawList;

      // server may return { success: true, message: "...", shops: [...] }
      if (decoded is Map<String, dynamic> && decoded['shops'] is List) {
        rawList = decoded['shops'] as List<dynamic>;
      } else if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else if (decoded is Map<String, dynamic>) {
        // try to find first List value in the map
        for (final v in decoded.values) {
          if (v is List) {
            rawList = v;
            break;
          }
        }
      }

      if (rawList == null) {
        throw Exception('Unexpected payload from server when fetching stores.');
      }

      final parsed = <Store>[];
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          parsed.add(Store.fromJson(item));
        } else if (item is Map) {
          parsed.add(Store.fromJson(Map<String, dynamic>.from(item)));
        } else {
          // skip unexpected items
          // ignore: avoid_print
          print('Skipping non-map item in shops list: ${item.runtimeType}');
        }
      }

      return parsed;
    } on SocketException catch (e) {
      // ignore: avoid_print
      print('SocketException in fetchStores: $e');
      throw Exception('Could not connect to server. Check your network or server status.');
    } on TimeoutException catch (e) {
      // ignore: avoid_print
      print('TimeoutException in fetchStores: $e');
      throw Exception('Request timed out. The server may be unreachable.');
    } on FormatException catch (e) {
      // ignore: avoid_print
      print('FormatException in fetchStores: $e');
      throw Exception('Invalid response format from server.');
    } catch (e) {
      // ignore: avoid_print
      print('Unknown error in fetchStores: $e');
      rethrow;
    }
  }

  /// Delete store (auth header included). Returns true if deleted.
  static Future<bool> deleteStore(String id, {Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    final headers = await _headers();

    try {
      final resp = await http.delete(uri, headers: headers).timeout(timeout);
      // ignore: avoid_print
      print('DELETE $uri -> ${resp.statusCode}: ${resp.body}');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } on SocketException catch (e) {
      // ignore: avoid_print
      print('SocketException in deleteStore: $e');
      throw Exception('Could not connect to server. Check your network or server status.');
    } on TimeoutException catch (e) {
      // ignore: avoid_print
      print('TimeoutException in deleteStore: $e');
      throw Exception('Request timed out. The server may be unreachable.');
    } catch (e) {
      // ignore: avoid_print
      print('Unknown error in deleteStore: $e');
      rethrow;
    }
  }

  /// Optional: fetch single store by id
  static Future<Store> fetchStoreById(String id, {Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    final headers = await _headers();

    try {
      final resp = await http.get(uri, headers: headers).timeout(timeout);
      // ignore: avoid_print
      print('GET $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('Failed to fetch store (status ${resp.statusCode})');
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return Store.fromJson(decoded);
      } else {
        throw Exception('Unexpected response shape for store');
      }
    } on SocketException catch (_) {
      throw Exception('Could not connect to server. Check your network or server status.');
    }
  }

  /// Optional: create or update store helpers (returns the created/updated store)
  static Future<Store> createStore(Map<String, dynamic> payload, {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/shops');
    final headers = await _headers();

    try {
      final resp = await http.post(uri, headers: headers, body: jsonEncode(payload)).timeout(timeout);
      // ignore: avoid_print
      print('POST $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 201 && resp.statusCode != 200) {
        throw Exception('Failed to create store (status ${resp.statusCode})');
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        // server might return wrapper or the store directly
        final storeMap = decoded['shop'] is Map ? decoded['shop'] as Map<String, dynamic> : decoded;
        return Store.fromJson(Map<String, dynamic>.from(storeMap));
      } else {
        throw Exception('Unexpected response when creating store');
      }
    } on SocketException catch (_) {
      throw Exception('Could not connect to server. Check your network or server status.');
    }
  }

  static Future<Store> updateStore(String id, Map<String, dynamic> payload, {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    final headers = await _headers();

    try {
      final resp = await http.put(uri, headers: headers, body: jsonEncode(payload)).timeout(timeout);
      // ignore: avoid_print
      print('PUT $uri -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('Failed to update store (status ${resp.statusCode})');
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        final storeMap = decoded['shop'] is Map ? decoded['shop'] as Map<String, dynamic> : decoded;
        return Store.fromJson(Map<String, dynamic>.from(storeMap));
      } else {
        throw Exception('Unexpected response when updating store');
      }
    } on SocketException catch (_) {
      throw Exception('Could not connect to server. Check your network or server status.');
    }
  }
}
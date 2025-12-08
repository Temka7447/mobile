import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilebiydaalt/models/store.dart';

class AdminService {
  // Use 10.0.2.2 for Android emulator. Replace with your PC LAN IP on a real device.
  static const String baseUrl = 'http://localhost:5000';

  // Get auth headers (include JWT if present)
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Fetch stores (handles plain list or common wrapper shapes).
  static Future<List<Store>> fetchStores() async {
    final uri = Uri.parse('$baseUrl/shops');
    final headers = await _headers();

    final resp = await http.get(uri, headers: headers);
    // ignore: avoid_print
    print('GET $uri -> ${resp.statusCode}: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch stores: ${resp.statusCode}');
    }

    final dynamic decoded = jsonDecode(resp.body);
    List<dynamic>? rawList;

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['shops'] is List) {
        rawList = decoded['shops'] as List<dynamic>;
      } else if (decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        for (final v in decoded.values) {
          if (v is List) {
            rawList = v;
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
  }

  /// Delete store (auth header included). Returns true if deleted.
  static Future<bool> deleteStore(String id) async {
    final uri = Uri.parse('$baseUrl/shops/$id');
    final headers = await _headers();

    final resp = await http.delete(uri, headers: headers);
    // ignore: avoid_print
    print('DELETE $uri -> ${resp.statusCode}: ${resp.body}');
    return resp.statusCode == 200 || resp.statusCode == 204;
  }
}
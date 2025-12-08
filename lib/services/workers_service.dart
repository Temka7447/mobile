import 'dart:convert';
import 'dart:async';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import 'package:mobilebiydaalt/services/admins_service.dart';

class WorkersService {
  static String get baseUrl => AdminService.baseUrl;

  /// Fetch workers (existing helper you already have)
  static Future<List<dynamic>> fetchWorkers({Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/workers');
    final resp = await http.get(uri).timeout(timeout);
    // ignore: avoid_print
    print('GET $uri -> ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) throw Exception('Failed to load workers: ${resp.statusCode}');
    final decoded = jsonDecode(resp.body);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['workers'] is List) return decoded['workers'] as List<dynamic>;
    // fallback: find first list
    if (decoded is Map) {
      for (final v in decoded.values) if (v is List) return v;
    }
    throw Exception('Unexpected payload for workers');
  }

  /// Create a new worker. Expects a map with keys like:
  /// { "name": "...", "phone": "...", "imageUrl": "...", "carNumber": "..." }
  /// Returns created worker map on success.
  static Future<Map<String, dynamic>> createWorker(Map<String, dynamic> payload,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/workers');
    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          .timeout(timeout);
      // ignore: avoid_print
      print('POST $uri -> ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode != 201 && resp.statusCode != 200) {
        final body = resp.body.isNotEmpty ? resp.body : 'status ${resp.statusCode}';
        throw Exception('Failed to create worker: $body');
      }
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      // if server wraps, try to return inner object
      if (decoded is Map && decoded['worker'] is Map) return Map<String, dynamic>.from(decoded['worker']);
      throw Exception('Unexpected create worker response');
    } on SocketException {
      throw Exception('Could not connect to server. Check network.');
    }
  }

  /// Update existing worker by id. payload same shape as createWorker.
  static Future<Map<String, dynamic>> updateWorker(String id, Map<String, dynamic> payload,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final uri = Uri.parse('$baseUrl/workers/$id');
    try {
      final resp = await http
          .put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          .timeout(timeout);
      // ignore: avoid_print
      print('PUT $uri -> ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode != 200) {
        final body = resp.body.isNotEmpty ? resp.body : 'status ${resp.statusCode}';
        throw Exception('Failed to update worker: $body');
      }
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map && decoded['worker'] is Map) return Map<String, dynamic>.from(decoded['worker']);
      throw Exception('Unexpected update worker response');
    } on SocketException {
      throw Exception('Could not connect to server. Check network.');
    }
  }

  /// Delete worker by id. Returns true on success.
  static Future<bool> deleteWorker(String id, {Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl/workers/$id');
    try {
      final resp = await http.delete(uri).timeout(timeout);
      // ignore: avoid_print
      print('DELETE $uri -> ${resp.statusCode}: ${resp.body}');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } on SocketException {
      throw Exception('Could not connect to server. Check network.');
    }
  }
}
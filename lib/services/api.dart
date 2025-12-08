import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";
  static Future<Map<String, dynamic>> registerUser(
      String name, String lastName, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "lastName": lastName,
          "phone": phone,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data as Map<String, dynamic>;
      } else {
        return {"error": data["error"] ?? "Failed to register user"};
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }
  static Future<Map<String, dynamic>> loginUser(
      String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = (data['token'] as String?) ?? '';
        final rawUser = (data['user'] is Map) ? data['user'] as Map<String, dynamic> : data as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        if (token.isNotEmpty) {
          await prefs.setString("jwt_token", token);
        }
        await prefs.setString("user_role", (rawUser['role'] as String?) ?? "user");
        await prefs.setString("user_phone", (rawUser['phone'] as String?) ?? "");
        final normalized = {
          "id": (rawUser['_id'] ?? rawUser['id'] ?? '').toString(),
          "name": (rawUser['name'] ?? '').toString(),
          "lastName": (rawUser['lastName'] ?? '').toString(),
          "phone": (rawUser['phone'] ?? '').toString(),
          "email": (rawUser['email'] ?? '').toString(),
          "role": (rawUser['role'] ?? 'user').toString(),
        };

        return {
          "token": token,
          "user": normalized,
        };
      } else {
        return {"error": data["error"] ?? data["message"] ?? "Failed to login user"};
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null || token.isEmpty) return {"error": "No token found"};

      final response = await http.get(
        Uri.parse("$baseUrl/users/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('GET $baseUrl/users/me -> ${response.statusCode}: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Server may return the user object at top-level or nested under "user".
        Map<String, dynamic> rawUser;
        if (data is Map && data['user'] is Map) {
          rawUser = Map<String, dynamic>.from(data['user'] as Map);
        } else if (data is Map && (data.containsKey('id') || data.containsKey('_id') || data.containsKey('name'))) {
          rawUser = Map<String, dynamic>.from(data as Map);
        } else {
          // Unexpected shape — return error
          return {"error": "Unexpected response shape from server"};
        }

        final id = (rawUser['_id'] ?? rawUser['id'] ?? '').toString();

        return {
          "id": id,
          "name": (rawUser['name'] ?? '').toString(),
          "lastName": (rawUser['lastName'] ?? '').toString(),
          "phone": (rawUser['phone'] ?? '').toString(),
          "email": (rawUser['email'] ?? '').toString(),
          "role": (rawUser['role'] ?? 'user').toString(),
        };
      } else {
        return {"error": data["error"] ?? data["message"] ?? "Failed to fetch user"};
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Update logged-in user ----------------
  static Future<Map<String, dynamic>> updateUser({
    required String name,
    required String lastName,
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null || token.isEmpty) return {"error": "No token found"};

      final response = await http.put(
        Uri.parse("$baseUrl/users/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "lastName": lastName,
          "phone": phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // server might return { user: {...} } or { updatedUser: {...} } or the user directly
        Map<String, dynamic> updated;
        if (data is Map && data['user'] is Map) {
          updated = Map<String, dynamic>.from(data['user'] as Map);
        } else if (data is Map && data['updatedUser'] is Map) {
          updated = Map<String, dynamic>.from(data['updatedUser'] as Map);
        } else if (data is Map && (data.containsKey('id') || data.containsKey('_id') || data.containsKey('name'))) {
          updated = Map<String, dynamic>.from(data as Map);
        } else {
          return {"error": "Unexpected response shape from server"};
        }

        final id = (updated['_id'] ?? updated['id'] ?? '').toString();
        return {
          "id": id,
          "name": (updated['name'] ?? '').toString(),
          "lastName": (updated['lastName'] ?? '').toString(),
          "phone": (updated['phone'] ?? '').toString(),
          "email": (updated['email'] ?? '').toString(),
          "role": (updated['role'] ?? 'user').toString(),
        };
      } else {
        return {"error": data["error"] ?? data["message"] ?? "Failed to update user"};
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Logout user ----------------
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.remove("user_role");
    await prefs.remove("user_phone");
  }
}
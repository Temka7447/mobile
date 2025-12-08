import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, replace with your PC IP for real device
  static const String baseUrl = "http://localhost:5000";

  // ---------------- Register user ----------------
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": jsonDecode(response.body)["error"] ?? "Failed to register user"
        };
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Login user ----------------
  static Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);

        return data;
      } else {
        return {
          "error": jsonDecode(response.body)["error"] ?? "Failed to login user"
        };
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Get logged-in user ----------------
  static Future<Map<String, dynamic>> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return {"error": "No token found"};

      final response = await http.get(
        Uri.parse("$baseUrl/users/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": jsonDecode(response.body)["error"] ?? "Failed to fetch user"
        };
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Update user ----------------
  static Future<Map<String, dynamic>> updateUser({
    required String name,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return {"error": "No token found"};

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
          "email": email,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": jsonDecode(response.body)["error"] ?? "Failed to update user"
        };
      }
    } catch (e) {
      return {"error": "Failed to connect to server: $e"};
    }
  }

  // ---------------- Logout user ----------------
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
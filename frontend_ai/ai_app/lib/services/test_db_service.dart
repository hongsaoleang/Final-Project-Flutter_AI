import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/test_db_item.dart';

class TestDbService {
  // Determine base host based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081/api/v1/items';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 is the Android emulator alias to the host machine's localhost
      return 'http://10.0.2.2:8081/api/v1/items';
    } else {
      return 'http://localhost:8081/api/v1/items';
    }
  }

  // Fetch all items from PostgreSQL
  static Future<List<TestDbItem>> fetchAllItems() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TestDbItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items: ${response.statusCode} - ${response.body}');
    }
  }

  // Add a new item into PostgreSQL
  static Future<TestDbItem> addItem(String username, String major) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'major': major,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TestDbItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add item: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete item from PostgreSQL
  static Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }
}

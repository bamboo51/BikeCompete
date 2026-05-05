import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.188.199/api';

  Future<Map<String, dynamic>> fetchHomeData() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load home data');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('$baseUrl/leaderboard'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load leaderboard');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchAccount() async {
    final response = await http.get(Uri.parse('$baseUrl/account'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load account');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
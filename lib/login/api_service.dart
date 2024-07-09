import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';

class ApiService {
  static String baseUrl = '';

  static Future<void> initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final mqttServerIp = prefs.getString('mqtt_server_ip') ?? '192.168.48.153';
    baseUrl = 'http://$mqttServerIp/test_api/';
  }

  Future<List<User>> fetchUsers() async {
    if (baseUrl.isEmpty) {
      await initializeBaseUrl();
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('auth_username');

    final url = username != null
        ? Uri.parse('$baseUrl/get_data.php?username=$username')
        : Uri.parse('$baseUrl/get_data.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout.php');
    final response = await http.post(
      url,
      body: {'token': token},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }
}

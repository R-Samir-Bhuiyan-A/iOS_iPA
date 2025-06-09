import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = 'http://103.151.60.203/app/ui.php';

  static void updateBaseUrl(String url) {
    baseUrl = url;
  }

  static Future<Map<String, dynamic>> fetchUI(String route) async {
    final response = await http.get(Uri.parse('$baseUrl?route=$route'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load UI');
    }
  }

  static Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/$endpoint'), body: data);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Post failed');
    }
  }
}

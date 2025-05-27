import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://103.151.60.203/Tour';

  static Future<Map<String, dynamic>> post(String path, Map body, {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': token,
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$path'),
      headers: {
        if (token != null) 'Authorization': token,
      },
    );
    return jsonDecode(response.body);
  }
}

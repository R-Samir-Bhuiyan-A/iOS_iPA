import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

const String apiUrl = 'http://103.151.60.203/slg/api.php';

class ApiService {
  static Future<String?> login(String username, String password) async {
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'login',
      'username': username,
      'password': password,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      await TokenStorage.saveToken(data['token']);
      return null; // No error
    }
    return data['error'] ?? 'Login failed';
  }

  static Future<String?> register(String username, String password) async {
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'register',
      'username': username,
      'password': password,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Registration failed';
  }

  static Future<List<dynamic>> getFeed() async {
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'get_feed',
      'token': token,
    });

    final data = json.decode(res.body);
    return data['feed'] ?? [];
  }

  static Future<String?> suggestSlang(String text) async {
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'add_slang',
      'token': token,
      'text': text,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Failed to suggest slang';
  }

  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}

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
    return data ?? [];
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

  static Future<String?> editSlang(String slangId, String newText) async {
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'edit_slang',
      'token': token,
      'id': slangId,
      'text': newText,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Failed to edit slang';
  }

  static Future<String?> deleteSlang(String slangId) async {
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'delete_slang',
      'token': token,
      'id': slangId,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Failed to delete slang';
  }

  static Future<String?> voteSlang(String slangId, String voteType) async {
    // voteType: "like" or "dislike"
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'vote_slang',
      'token': token,
      'id': slangId,
      'vote': voteType,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Failed to vote slang';
  }

  static Future<Map<String, dynamic>?> getSlangOfTheWeek() async {
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'get_slang_of_the_week',
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return data['slang'];
    }
    return null;
  }

  static Future<String?> claimPoints() async {
    final token = await TokenStorage.getToken();
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'claim_points',
      'token': token,
    });

    final data = json.decode(res.body);
    if (data['success'] == true) {
      return null;
    }
    return data['error'] ?? 'Failed to claim points';
  }

  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  String? get userId => _user?['id']; // ✅ add this getter

  Future<bool> login(String username, String password) async {
    final response = await ApiService.post('modules/user/login.php', {
      'username': username,
      'password': password,
    });

    if (response['status'] == 'success') {
      _token = response['token'];
      _user = response['user']; // ✅ make sure backend returns user info

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', response['user'].toString());
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    final response = await ApiService.post('modules/user/register.php', {
      'username': username,
      'email': email,
      'password': password,
    });

    return response['status'] == 'success';
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;

    _token = prefs.getString('auth_token');

    // Optional: Load user data if stored
    final userString = prefs.getString('user_data');
    if (userString != null) {
      try {
        _user = Map<String, dynamic>.from(
          Uri.splitQueryString(userString.replaceAll(RegExp('[{}]'), '')),
        );
      } catch (_) {
        _user = null;
      }
    }

    notifyListeners();
  }
}

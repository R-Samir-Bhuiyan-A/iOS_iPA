import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<bool> login(String username, String password) async {
    final response = await ApiService.post('modules/user/login.php', {
      'username': username,
      'password': password,
    });

    if (response['status'] == 'success') {
      _token = response['token'];  // assuming backend sends token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;
    _token = prefs.getString('auth_token');
    notifyListeners();
  }
}

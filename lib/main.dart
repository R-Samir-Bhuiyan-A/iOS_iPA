import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/token_storage.dart';

void main() {
  runApp(const ShawarApp());
}

class ShawarApp extends StatefulWidget {
  const ShawarApp({Key? key}) : super(key: key);

  @override
  State<ShawarApp> createState() => _ShawarAppState();
}

class _ShawarAppState extends State<ShawarApp> {
  String? _token;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await TokenStorage.getToken();
    setState(() {
      _token = token;
      _loading = false;
    });
  }

  void _onLoginSuccess() async {
    final token = await TokenStorage.getToken();
    setState(() => _token = token);
  }

  void _onLogout() {
    setState(() => _token = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Shawar Slang App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: _token == null
          ? LoginScreen(onLogin: _onLoginSuccess)
          : HomeScreen(onLogout: _onLogout),
    );
  }
}

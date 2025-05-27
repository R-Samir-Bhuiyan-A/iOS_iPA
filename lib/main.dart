import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/block_screen.dart'; // 👈 Add this
import 'utils/token_storage.dart';
import 'services/device_checker.dart'; // 👈 Add this

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
  bool _allowed = true;
  String? _blockMessage;
  String? _blockLink;

  @override
  void initState() {
    super.initState();
    _checkAccessAndToken();
  }

  Future<void> _checkAccessAndToken() async {
    final access = await DeviceChecker.isAllowed();

    if (!access['allow']) {
      setState(() {
        _allowed = false;
        _blockMessage = access['message'];
        _blockLink = access['link'];
        _loading = false;
      });
      return;
    }

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

    if (!_allowed) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlockScreen(
          message: _blockMessage ?? "App access is blocked by admin.",
          link: _blockLink,
        ),
      );
    }

    return MaterialApp(
      title: 'Shawar App',
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

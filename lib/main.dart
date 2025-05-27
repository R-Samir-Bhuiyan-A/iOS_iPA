import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/tournament_provider.dart';
import 'providers/wallet_provider.dart'; // Added WalletProvider import

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tournament/tournament_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()), // Added WalletProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Free Fire Tournament',
        theme: darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashOrHome(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => TournamentListScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}

class SplashOrHome extends StatefulWidget {
  @override
  _SplashOrHomeState createState() => _SplashOrHomeState();
}

class _SplashOrHomeState extends State<SplashOrHome> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoLogin();
    setState(() {
      _loggedIn = authProvider.isLoggedIn;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _loggedIn ? TournamentListScreen() : LoginScreen();
  }
}

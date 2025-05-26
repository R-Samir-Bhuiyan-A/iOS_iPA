import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  ProfileScreen({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // For now just show Logout button, you can add user info here later
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ApiService.logout();
            onLogout();
            Navigator.pop(context);
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}

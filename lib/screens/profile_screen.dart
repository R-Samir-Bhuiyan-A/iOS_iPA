import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userInfo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final response = await ApiService.get('modules/user/profile.php', token: token);
    if (response['status'] == 'success') {
      setState(() {
        userInfo = response['data'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : userInfo == null
              ? Center(child: Text('Failed to load profile'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username: ${userInfo!['username']}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Email: ${userInfo!['email']}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Wallet Balance: ${userInfo!['wallet_balance']}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Logout'),
                      )
                    ],
                  ),
                ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String deviceInfo = '';
  String appInfo = '';
  String developerInfo = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    String devInfo = 'Not available';
    try {
      final res = await http.get(Uri.parse('http://103.151.60.203/slg/admin/info.php'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        devInfo = data['developer'] ?? 'Unknown developer';
      }
    } catch (e) {
      devInfo = 'Failed to load';
    }

    final device = await DeviceInfoPlugin().deviceInfo;
    String model = 'Unknown';
    String os = 'Unknown';

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      model = '${info.manufacturer} ${info.model}';
      os = 'Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      model = '${info.name} ${info.model}';
      os = '${info.systemName} ${info.systemVersion}';
    }

    final pkg = await PackageInfo.fromPlatform();

    setState(() {
      developerInfo = devInfo;
      deviceInfo = '$model\n$os';
      appInfo = '${pkg.appName} v${pkg.version}+${pkg.buildNumber}';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('App Info'),
                      subtitle: Text(appInfo),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: const Text('Device Info'),
                      subtitle: Text(deviceInfo),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.developer_mode),
                      title: const Text('Developer Info'),
                      subtitle: Text(developerInfo),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      ApiService.logout();
                      widget.onLogout();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class DeviceChecker {
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = 'unknown';
    String os = 'unknown';

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceId = android.id ?? 'unknown'; // ✅ Only use `.id`
      os = 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? 'unknown';
      os = '${ios.systemName} ${ios.systemVersion}';
    }

    // Get public IP
    final ipResp = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
    final ip = jsonDecode(ipResp.body)['ip'];

    return {
      'device_id': deviceId,
      'ip': ip,
      'os': os,
      'app_version': packageInfo.version,
    };
  }

  static Future<Map<String, dynamic>> isAllowed() async {
    final info = await getDeviceInfo();

    final response = await http.post(
      Uri.parse('http://103.151.60.203/slg/admin/admin.php?action=check'),
      body: info,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {'allow': true}; // default to allowed
  }
}

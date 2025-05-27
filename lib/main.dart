import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String adminApiBase = 'http://103.151.60.203/slg/admin/admin.php';

void main() {
  runApp(ShawarAdminApp());
}

class ShawarAdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shawar Admin',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          secondary: Colors.tealAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
        ),
      ),
      home: AdminPanelScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<Map<String, dynamic>> devices = [];
  bool isLoading = false;
  bool globalPause = false;
  String pauseMessage = '';
  String pauseLink = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchDevices();
    fetchGlobalPauseStatus();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final res = await http.get(Uri.parse('$adminApiBase?action=list'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>? ?? {};
        devices = data.entries
            .map((e) => {
                  "device_id": e.key,
                  ...Map<String, dynamic>.from(e.value),
                })
            .toList();
      } else {
        error = 'Failed to load devices: ${res.statusCode}';
      }
    } catch (e) {
      error = 'Failed to load devices: $e';
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchGlobalPauseStatus() async {
    try {
      final res = await http.get(Uri.parse('http://103.151.60.203/slg/admin/rules.json'));
      if (res.statusCode == 200) {
        final rulesData = json.decode(res.body);
        setState(() {
          globalPause = rulesData['global_pause'] ?? false;
          pauseMessage = rulesData['pause_message'] ?? '';
          pauseLink = rulesData['pause_link'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> blockDevice(String deviceId, String message) async {
    final uri = Uri.parse(
        '$adminApiBase?action=block&device_id=${Uri.encodeComponent(deviceId)}&message=${Uri.encodeComponent(message)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['status'] == 'blocked') {
        _showSnack('Device blocked successfully');
        fetchDevices();
      } else if (data['error'] != null) {
        _showSnack('Error: ${data['error']}');
      }
    } else {
      _showSnack('Failed to block device');
    }
  }

  Future<void> unblockDevice(String deviceId) async {
    final uri =
        Uri.parse('$adminApiBase?action=unblock&device_id=${Uri.encodeComponent(deviceId)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['status'] == 'unblocked') {
        _showSnack('Device unblocked successfully');
        fetchDevices();
      } else if (data['error'] != null) {
        _showSnack('Error: ${data['error']}');
      }
    } else {
      _showSnack('Failed to unblock device');
    }
  }

  Future<void> toggleGlobalPause(bool pause, String message, String link) async {
    final uri = Uri.parse(
        '$adminApiBase?action=pause_all&status=${pause ? '1' : '0'}&message=${Uri.encodeComponent(message)}&link=${Uri.encodeComponent(link)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['status'] == 'paused_all' || data['status'] == 'resumed_all') {
        _showSnack('Global pause updated');
        fetchGlobalPauseStatus();
      } else if (data['error'] != null) {
        _showSnack('Error: ${data['error']}');
      }
    } else {
      _showSnack('Failed to update global pause');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showBlockDialog(String deviceId) {
    final controller = TextEditingController(text: "Your device has been blocked by admin.");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF222222),
        title: Text('Block Device', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Block Message',
            labelStyle: TextStyle(color: Colors.tealAccent),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Block'),
            onPressed: () {
              blockDevice(deviceId, controller.text.trim());
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _showGlobalPauseDialog() {
    final msgController = TextEditingController(text: pauseMessage);
    final linkController = TextEditingController(text: pauseLink);
    bool isPaused = globalPause;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Color(0xFF222222),
            title: Text('Global Pause Settings', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: isPaused,
                  onChanged: (v) => setDialogState(() => isPaused = v),
                  title: Text('Pause All Access', style: TextStyle(color: Colors.white)),
                ),
                TextField(
                  controller: msgController,
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Pause Message',
                    labelStyle: TextStyle(color: Colors.tealAccent),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: linkController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Pause Link (optional)',
                    labelStyle: TextStyle(color: Colors.tealAccent),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  toggleGlobalPause(
                    isPaused,
                    msgController.text.trim(),
                    linkController.text.trim(),
                  );
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      ),
    );
  }

  Widget deviceCard(Map<String, dynamic> device) {
    final bool blocked = device['blocked'] == true;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          device['device_id'] ?? 'Unknown ID',
          style: TextStyle(
            color: blocked ? Colors.redAccent : Colors.tealAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          blocked ? 'Blocked' : 'Active',
          style: TextStyle(color: blocked ? Colors.redAccent : Colors.greenAccent),
        ),
        children: [
          ListTile(title: Text('IP: ${device['ip'] ?? 'N/A'}')),
          ListTile(title: Text('OS: ${device['os'] ?? 'N/A'}')),
          ListTile(title: Text('App Version: ${device['version'] ?? 'N/A'}')),
          ListTile(title: Text('Last Active: ${device['last_active'] ?? 'N/A'}')),
          if (blocked)
            ListTile(
              title: Text('Block Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(device['block_message'] ?? 'No message'),
            ),
          ButtonBar(
            children: [
              if (!blocked)
                ElevatedButton(
                  onPressed: () => _showBlockDialog(device['device_id']),
                  child: Text('Block'),
                ),
              if (blocked)
                ElevatedButton(
                  onPressed: () => unblockDevice(device['device_id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  child: Text('Unblock', style: TextStyle(color: Colors.black)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shawar Admin'),
        actions: [
          IconButton(
            tooltip: 'Global Pause Settings',
            icon: Icon(Icons.pause_circle),
            onPressed: _showGlobalPauseDialog,
          ),
          IconButton(
            tooltip: 'Refresh Devices',
            icon: Icon(Icons.refresh),
            onPressed: fetchDevices,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
              : devices.isEmpty
                  ? Center(child: Text('No devices found', style: TextStyle(color: Colors.white70)))
                  : RefreshIndicator(
                      onRefresh: fetchDevices,
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (_, i) => deviceCard(devices[i]),
                      ),
                    ),
    );
  }
}

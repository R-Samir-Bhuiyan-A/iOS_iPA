import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DynamicUIState(),
      child: const DynamicUIApp(),
    ),
  );
}

class DynamicUIApp extends StatelessWidget {
  const DynamicUIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic UI App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DynamicUIScreen(),
    );
  }
}

// Provider to hold UI state and input controllers
class DynamicUIState extends ChangeNotifier {
  List<Map<String, dynamic>> widgets = [];
  final Map<String, TextEditingController> controllers = {};
  bool loading = true;
  String? error;

  Future<void> loadUI() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('http://103.151.60.203/app/ui.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['type'] == 'Column' && jsonData['children'] != null) {
          widgets = List<Map<String, dynamic>>.from(jsonData['children']);
          // Initialize controllers for any TextFields
          for (var widgetData in widgets) {
            if (widgetData['type'] == 'TextField' && widgetData.containsKey('key')) {
              final key = widgetData['key'];
              if (!controllers.containsKey(key)) {
                controllers[key] = TextEditingController();
              }
            }
          }
          loading = false;
          notifyListeners();
        } else {
          error = "Invalid UI schema";
          loading = false;
          notifyListeners();
        }
      } else {
        error = "Failed to fetch UI: HTTP ${response.statusCode}";
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      error = "Error loading UI: $e";
      loading = false;
      notifyListeners();
    }
  }

  void removeWidgetByKey(String key) {
    widgets.removeWhere((element) => element['key'] == key);
    controllers.remove(key);
    notifyListeners();
  }

  Future<void> handleAction(Map<String, dynamic> action) async {
    final type = action['type'];
    if (type == 'remove') {
      final targetKey = action['targetKey'];
      if (targetKey != null) {
        removeWidgetByKey(targetKey);
      }
    } else if (type == 'post') {
      final url = action['url'];
      final params = action['params'] as Map<String, dynamic>? ?? {};
      // Replace param values starting with '@' with input controller values
      final data = <String, dynamic>{};
      params.forEach((key, value) {
        if (value is String && value.startsWith('@')) {
          final controllerKey = value.substring(1);
          data[key] = controllers[controllerKey]?.text ?? '';
        } else {
          data[key] = value;
        }
      });

      try {
        final response = await http.post(Uri.parse(url), body: data);
        if (response.statusCode == 200) {
          // Success feedback could be handled here
          // For demo, show a dialog
          print('POST success: ${response.body}');
        } else {
          print('POST failed: ${response.statusCode}');
        }
      } catch (e) {
        print('POST error: $e');
      }
    }
  }
}

class DynamicUIScreen extends StatefulWidget {
  const DynamicUIScreen({Key? key}) : super(key: key);

  @override
  State<DynamicUIScreen> createState() => _DynamicUIScreenState();
}

class _DynamicUIScreenState extends State<DynamicUIScreen> {
  @override
  void initState() {
    super.initState();
    final uiState = context.read<DynamicUIState>();
    uiState.loadUI();
  }

  Widget buildWidget(BuildContext context, Map<String, dynamic> data) {
    final uiState = context.read<DynamicUIState>();

    switch (data['type']) {
      case 'Text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(data['text'] ?? '',
              style: TextStyle(
                fontSize: (data['fontSize'] != null) ? data['fontSize'].toDouble() : 16,
                fontWeight: (data['bold'] == true) ? FontWeight.bold : FontWeight.normal,
              )),
        );

      case 'TextField':
        final key = data['key'] ?? UniqueKey().toString();
        final controller = uiState.controllers.putIfAbsent(key, () => TextEditingController());
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: data['hintText'] ?? '',
              border: const OutlineInputBorder(),
            ),
          ),
        );

      case 'Button':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              if (data.containsKey('action')) {
                uiState.handleAction(Map<String, dynamic>.from(data['action']));
              }
            },
            child: Text(data['text'] ?? 'Button'),
          ),
        );

      case 'Column':
        final children = (data['children'] as List<dynamic>?)
                ?.map((child) => buildWidget(context, Map<String, dynamic>.from(child)))
                .toList() ??
            [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

      case 'Row':
        final children = (data['children'] as List<dynamic>?)
                ?.map((child) => buildWidget(context, Map<String, dynamic>.from(child)))
                .toList() ??
            [];
        return Row(
          children: children,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicUIState>(
      builder: (context, uiState, _) {
        if (uiState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (uiState.error != null) {
          return Center(child: Text('Error: ${uiState.error}'));
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: buildWidget(
                context,
                {
                  "type": "Column",
                  "children": uiState.widgets,
                }
            ),
          );
        }
      },
    );
  }
}

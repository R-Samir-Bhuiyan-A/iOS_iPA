import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuggestScreen extends StatefulWidget {
  @override
  _SuggestScreenState createState() => _SuggestScreenState();
}

class _SuggestScreenState extends State<SuggestScreen> {
  final _controller = TextEditingController();
  bool isLoading = false;
  String? error;

  void suggest() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    final err = await ApiService.suggestSlang(text);

    setState(() {
      isLoading = false;
      error = err;
    });

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Slang suggested!')));
      Navigator.pop(context, true); // return true to refresh feed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suggest New Slang')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Slang text',
                errorText: error,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading)
              ElevatedButton(
                onPressed: suggest,
                child: Text('Submit'),
              )
          ],
        ),
      ),
    );
  }
}

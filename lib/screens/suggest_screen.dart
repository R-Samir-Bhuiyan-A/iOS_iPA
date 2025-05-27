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
    if (text.isEmpty) {
      setState(() {
        error = 'Please enter some slang text';
      });
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slang suggested! Thanks for your contribution.'),
          backgroundColor: Colors.green[600],
        ),
      );
      Navigator.pop(context, true); // return true to refresh feed
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = !isLoading && _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggest New Slang'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your slang suggestion here...',
                    errorText: error,
                    counterText: '', // hide counter text for cleaner UI
                  ),
                  onChanged: (_) => setState(() {}), // update button state
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? suggest : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit Suggestion', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

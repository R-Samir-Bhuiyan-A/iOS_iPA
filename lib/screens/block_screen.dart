import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockScreen extends StatelessWidget {
  final String message;
  final String? link;

  const BlockScreen({super.key, required this.message, this.link});

  void _openLink(BuildContext context) async {
    if (link != null && await canLaunchUrl(Uri.parse(link!))) {
      launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the link.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 60, color: Colors.red.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'App Blocked',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (link != null) ...[
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => _openLink(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Get Help"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

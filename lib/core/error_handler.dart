import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Widget buildErrorWidget(String message) {
    return Center(
      child: Text("⚠️ $message", style: const TextStyle(color: Colors.red)),
    );
  }
}

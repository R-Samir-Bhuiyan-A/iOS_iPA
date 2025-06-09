import 'package:flutter/material.dart';

class Utils {
  static Color parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static bool isValidJson(Map<String, dynamic> json) {
    return json.containsKey('type') && json['type'] is String;
  }
}

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String apiUrl = 'http://103.151.60.203/app/ui.php';
  ThemeMode themeMode = ThemeMode.system;

  void updateApiUrl(String newUrl) {
    apiUrl = newUrl;
    notifyListeners();
  }

  void toggleThemeMode() {
    themeMode = (themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

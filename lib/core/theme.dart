import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurpleAccent,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurpleAccent,
    secondary: Colors.deepPurpleAccent,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'Roboto',
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.deepPurpleAccent,
    textTheme: ButtonTextTheme.primary,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.deepPurpleAccent, // <-- use foregroundColor instead of primary
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[900],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
);

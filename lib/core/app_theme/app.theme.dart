import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF9F7AEA),
    scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(68, 137, 255, 0),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
        fixedSize: const Size(500, 50),
        backgroundColor: const Color(0xFF9F7AEA),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(198, 255, 255, 255),
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 10),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 245, 87, 84),
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 255, 255, 255),
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Color(0xFF2A2C36),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
    ),
  );
}

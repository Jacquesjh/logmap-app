import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var appTheme = ThemeData(
  fontFamily: GoogleFonts.nunito().fontFamily,
  primaryColor: const Color(0xFF08F26E), // Set primary color to #08F26E
  scaffoldBackgroundColor: const Color.fromARGB(255, 158, 158, 158),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Color.fromARGB(255, 42, 42, 42),
  ),
  brightness: Brightness.dark,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    labelLarge: TextStyle(
      letterSpacing: 1.5,
      fontWeight: FontWeight.bold,
    ),
    displayLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
    ),
  ),
  buttonTheme: const ButtonThemeData(),
);

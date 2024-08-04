import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xff38e078),
    secondary: Color.fromARGB(255, 65, 101, 184),
    tertiary: Colors.white,
    surface: Color(0xfff5f5f5),
  ),
  textTheme: GoogleFonts.publicSansTextTheme(),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(255, 65, 101, 184),
    secondary: Color.fromARGB(255, 160, 189, 255),
    tertiary: Colors.black,
    surface: Color(0xfff5f5f5),
  ),
  textTheme: GoogleFonts.publicSansTextTheme(),
);
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Color(0xffFFFFFC),
    primary: Color(0xff012271),
    secondary: Color.fromARGB(255, 65, 101, 184),
    tertiary: Colors.white,
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Color(0xff292929),
    primary: Color.fromARGB(255, 65, 101, 184),
    secondary: Color.fromARGB(255, 160, 189, 255),
    tertiary: Colors.black,
  ),
);
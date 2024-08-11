import 'package:flutter/material.dart';
import 'package:running_log/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  ThemeProvider (bool isLight) {
    if (isLight) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }
  }

  void toggleTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (_themeData == lightMode) {
      themeData = darkMode;
      sharedPreferences.setBool("light_mode", false);
    } else {
      themeData = lightMode;
      sharedPreferences.setBool("light_mode", true);
    }
    notifyListeners();
  }
}
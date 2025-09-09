import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: Colors.orangeAccent,
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.orangeAccent.shade700,
  useMaterial3: true,
);

import 'package:flutter/material.dart';

import 'package:MyNews/shared/global_values.dart';

ThemeData getAndroidThemeData(int index) {
  return ThemeData(
      // Theme Settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      accentColor: accentColors[index],
      primaryColor: Colors.white,
      fontFamily: 'Roboto');
}

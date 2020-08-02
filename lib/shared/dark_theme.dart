import 'package:flutter/material.dart';

import 'package:MyNews/shared/global_values.dart';

// Dark ThemeData
ThemeData darkThemeData(int index) {
  return ThemeData(
      // Dark Theme Settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      accentColor: accentColors[index],
      canvasColor: Colors.black,
      dividerColor: Colors.grey,
      fontFamily: 'Roboto');
}

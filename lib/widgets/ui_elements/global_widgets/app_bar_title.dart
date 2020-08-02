import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  // Class Attributes
  final String title;

  // Constructor
  AppBarTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 23,
        ),
      ),
    );
  }
}

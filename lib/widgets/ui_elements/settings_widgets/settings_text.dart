import 'package:flutter/material.dart';

// settings text container

class SettingsText extends StatelessWidget {
  SettingsText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 10, top: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 15,
        ),
      ),
    );
  }
}

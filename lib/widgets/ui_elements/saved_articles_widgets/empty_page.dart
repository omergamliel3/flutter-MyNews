import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(15.0),
      child: Text(
        'There are no saved Articles'.toUpperCase(),
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

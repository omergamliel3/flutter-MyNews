import 'package:flutter/material.dart';

import 'package:MyNews/shared/global_values.dart';

// Welcome Dialog Class

class WelcomeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      title: Row(
        children: <Widget>[
          Image.asset(
            'Assets/images/loading_screen_logo.png',
            height: 50,
            width: 50,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            appName,
            style: TextStyle(fontSize: 22),
          )
        ],
      ),
      content: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'We are trying our best to personalize your news reading experience',
          ),
          Text(
            '\nSend feedback to help us improve the app'.toUpperCase(),
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      )),
      actions: <Widget>[
        FlatButton(
          // Go back button
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            // pop dialog
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

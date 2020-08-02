import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class ThemeListTile extends StatefulWidget {
  @override
  _ThemeListTileState createState() => _ThemeListTileState();

  final Function changeState;
  final MainModel model;

  ThemeListTile(this.changeState, this.model);
}

class _ThemeListTileState extends State<ThemeListTile> {
// UnFocusScope Method, creates a new FocusNode
  void _unFocusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    // ScopedModed listener to theme change
    return ListTile(
      // title change depends on the brightness
      leading: Icon(
        widget.model.isDark ? Icons.brightness_low : Icons.brightness_high,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Dark Mode'),
      trailing: Switch(
        // the value is false if brightness is light and true if brightness is dark
        value: widget.model.isDark,
        // call changeThemeMode from main when Changed
        onChanged: (value) {
          _unFocusScope();
          // change theme from global state model
          widget.model.changeTheme();
          // call changeState method to setState from main
          widget.changeState();
          // set new value in prefs
          widget.model.sharedPreferences.setBool('isDark', value);
        },
        activeColor: Theme.of(context).accentColor,
      ),
      onTap: () {
        _unFocusScope();
        // change theme from global state model
        widget.model.changeTheme();
        // call changeState method to setState from main
        widget.changeState();
        // set new value in prefs

        widget.model.sharedPreferences.setBool('isDark', widget.model.isDark);
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class TimeSearchMenu extends StatefulWidget {
  @override
  _TimeSearchMenuState createState() => _TimeSearchMenuState();

  // searchDateMode enum value

  final MainModel _model;

  TimeSearchMenu(this._model);
}

class _TimeSearchMenuState extends State<TimeSearchMenu> {
  SearchDateMode _searchDateMode;

  @override
  void initState() {
    _searchDateMode = widget._model.searchDateMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Icon(
          Icons.star,
          color: Theme.of(context).accentColor,
        ),
        title: Text('Following Search Time'),
        trailing: DropdownButton<SearchDateMode>(
          items: [
            DropdownMenuItem(
              child: Text('Default'),
              value: SearchDateMode.Default,
            ),
            DropdownMenuItem(
              child: Text('Week'),
              value: SearchDateMode.Week,
            ),
            DropdownMenuItem(
              child: Text('Month'),
              value: SearchDateMode.Month,
            ),
            DropdownMenuItem(
              child: Text('Custom'),
              value: SearchDateMode.Custom,
            ),
          ],
          value: _searchDateMode,
          onChanged: (SearchDateMode value) {
            // save value in prefs
            widget._model.setSearchDateMode(value);
            // change the value
            setState(() {
              _searchDateMode = value;
            });
          },
        ),
      ),
    );
  }
}

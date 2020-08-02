import 'package:flutter/material.dart';

class RestoreDefaultsListTile extends StatelessWidget {
  final Function _deletePrefs;
  RestoreDefaultsListTile(this._deletePrefs);

  // show dialog method for delete search history
  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // alert dialog widget
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text('Restore to defaults?'.toUpperCase()),
            content: Text('You won\'t be able to undo this.'),
            actions: <Widget>[
              FlatButton(
                // Back button
                child: Text(
                  'BACK',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                // OK button
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  _deletePrefs();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        _showAlertDialog(context);
      },
      title: Text('Restore Settings To Defaults'),
      leading: Icon(
        Icons.restore,
        color: Theme.of(context).accentColor,
      ),
    );
  }
}

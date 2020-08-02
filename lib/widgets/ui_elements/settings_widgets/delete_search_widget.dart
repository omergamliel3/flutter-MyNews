import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class DeleteSearchWidget extends StatelessWidget {
  final String prefsKey = 'suggestions';

  // show dialog method for delete search history
  void _showAlertDialog(
    BuildContext context,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // alert dialog widget
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text('delete search history?'.toUpperCase()),
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
                  // clear suggestion from prefs
                  MainModel.of(context).sharedPreferences.remove('prefsKey');
                  // set saved search news title to empty string (remove last search there is one)
                  MainModel.of(context).setSavedSearchNewsTitle('');
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
      leading: Icon(
        Icons.delete,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Delete Search History'),
    );
  }
}

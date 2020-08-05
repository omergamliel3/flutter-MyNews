import 'package:flutter/material.dart';
import 'package:MyNews/scoped-models/main.dart';

// RemoveDialog class

class RemoveDialog extends StatelessWidget {
  // Class Attributes
  final String categorie;
  final MainModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function removeLocal;
  final int index;

  // Constructor
  RemoveDialog(
      {@required this.categorie,
      @required this.model,
      @required this.scaffoldKey,
      @required this.removeLocal,
      @required this.index});

  // submit method
  void submit(BuildContext context) async {
    // if the current removed categorie is the last index page set the pageIndex
    if (model.getfollowingTopicsList.length - 1 ==
        model.followingPageTabBarIndex) {
      model.setTabBarIndex(model.followingPageTabBarIndex - 1);
    }
    // call remvoe categorie from MainModel
    await model.removeFollowing(index);
    // remove FocusNode
    removeLocal();
    // show snackbar
    showSnackBar(context);
    Navigator.of(context).pop();
  }

  // show remove categorie SnackBar, called after submit method
  void showSnackBar(BuildContext context) {
    Color textColor = model.isDark ? Theme.of(context).accentColor : null;
    // snackBar
    SnackBar snackBar = SnackBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).primaryColor
          : null,
      duration: Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(
        '$categorie removed from Following',
        style: TextStyle(color: textColor),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Text(
        'Remove $categorie?',
      ),
      content: SingleChildScrollView(
        child: Text(
          'You won\'t be able to undo this',
        ),
      ),
      actions: <Widget>[
        FlatButton(
          // Go back button
          child: Text(
            'BACK',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            // Go back when pressed
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          // OK back button
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () => submit(context),
        )
      ],
    );
  }
}

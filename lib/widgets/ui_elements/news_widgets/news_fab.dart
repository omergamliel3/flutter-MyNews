import 'dart:math' as math;

import 'package:MyNews/models/article.dart';
import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/services/db_service.dart';
import 'package:flutter/material.dart';

import 'package:share/share.dart';

class NewsFAB extends StatefulWidget {
  @override
  _NewsFABState createState() => _NewsFABState();
}

class _NewsFABState extends State<NewsFAB> with TickerProviderStateMixin {
  // animation controller
  AnimationController _controller;

  @override
  void initState() {
    // set animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

// show dialog method for delete button
  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // alert dialog widget
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text('Delete all atricles?'.toUpperCase()),
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
                onPressed: () async {
                  // delete all articles from db service
                  await DBservice.deleteAllArticles();
                  // notify UI update
                  MainModel.of(context).callNotifyListeners();
                  Navigator.of(context).pop();
                  _controller.reverse();
                },
              ),
            ],
          );
        });
  }

  /// share all saved articles with the [Share] plugin
  void _shareSavedArticles(List<Article> articles) {
    String str = 'Check out my favorite articles:\n';
    for (var i = 0; i < articles.length; i++) {
      str += '\n${articles[i].title}:\n${articles[i].url}\n';
    }
    Share.share(str);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          // Share Container
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
                // set the curved animation
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).accentColor,
              heroTag: 'share',
              mini: true,
              onPressed: () async {
                List<Article> articles = await DBservice.getArticles();
                if (articles.length == 0) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('There are no saved articles to share'),
                    duration: Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.fixed,
                  ));
                } else {
                  // Call share method
                  _shareSavedArticles(articles);
                }
              },
              child: Icon(
                // mail icon
                Icons.share,
                color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).accentColor
                    : null,
              ),
            ),
          ),
        ),
        Container(
          // Delete Container
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
                // set the curved animation
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).accentColor,
              heroTag: 'delete',
              mini: true,
              onPressed: () async {
                List<Article> articles = await DBservice.getArticles();
                if (articles.length == 0) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('There are no saved articles to delete'),
                    duration: Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.fixed,
                  ));
                } else
                  _showDeleteDialog();
              },
              child: Icon(
                Icons.delete,
                color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).accentColor
                    : null,
              ),
            ),
          ),
        ),
        Container(
            // Options Container
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: FloatingActionButton(
              heroTag: 'options',
              onPressed: () {
                // forward or reverse according to the animation controller
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              backgroundColor: Theme.of(context).accentColor,
              child: AnimatedBuilder(
                // Animated More, Close Icon
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                    // set the transformatin
                    alignment: FractionalOffset.center,
                    child: Icon(_controller.isDismissed
                        ? Icons.more_vert
                        : Icons.close),
                    transform: // rotation on the z axis
                        Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  );
                },
              ),
            )),
      ],
    );
  }
}

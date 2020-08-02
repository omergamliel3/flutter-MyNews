import 'package:flutter/material.dart';

import 'package:MyNews/models/news.dart';

import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/models/article.dart';

import 'package:MyNews/services/db_service.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

class SaveButton extends StatefulWidget {
  @override
  _SaveButtonState createState() => _SaveButtonState();

  final MainModel model;
  final News news;
  final Stream<void> triggerAnimationStream;

  SaveButton(this.model, this.news, {this.triggerAnimationStream});
}

class _SaveButtonState extends State<SaveButton> with TickerProviderStateMixin {
  // heart animation
  Animation _saveAnimation;
  // heart animation controller
  AnimationController _saveAnimationController;
  bool _isFavorite;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // set the heart animation controller
    _saveAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    // set the heart animation
    _saveAnimation = Tween(begin: 25.0, end: 40.0).animate(CurvedAnimation(
        curve: Curves.easeOut, parent: _saveAnimationController));
    // add listener to the animation controller
    _saveAnimationController.addStatusListener((AnimationStatus status) {
      // when status complete animation reverse
      if (status == AnimationStatus.completed) {
        _saveAnimationController.reverse();
      }
    });

    if (widget.triggerAnimationStream != null) {
      widget.triggerAnimationStream.listen((_) {
        _saveAnimationController.forward();
        setState(() {
          if (_isFavorite == false) {
            _isFavorite = true;
          }
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _saveAnimationController.dispose();
    super.dispose();
  }

  // press favorites method
  void _pressFavorite() async {
    _saveAnimationController.forward();
    bool complete;

    if (_isFavorite) {
      // delete article from DB
      complete = await DBservice.deleteArticle(widget.news.url);
    } else {
      // add article to DB
      complete = await DBservice.addArticle(Article(
          url: widget.news.url,
          urlToImage: widget.news.urlToImage,
          date: widget.news.publishedAt,
          source: widget.news.source,
          textDirection: widget.news.textDir,
          title: widget.news.title));
    }

    if (!complete) {
      Fluttertoast.showToast(
          msg: 'Can\'t save article',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
      return;
    }

    // notify UI update
    widget.model.callNotifyListeners();

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        _isFavorite = DBservice.isSaved(widget.news.url);
        return IconButton(
          tooltip: 'Save',
          icon: AnimatedBuilder(
            animation: _saveAnimationController,
            builder: (context, child) {
              return Icon(
                _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: _isFavorite ? Colors.green : null,
                size: _saveAnimation.value,
              );
            },
          ),
          // pressFavorite methos
          onPressed: () {
            _pressFavorite();
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:share/share.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:MyNews/services/db_service.dart';

import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/models/article.dart';

import '../../widgets/ui_elements/saved_articles_widgets/index.dart';

class SavedArticlesPage extends StatefulWidget {
  // Class Attributes
  final MainModel model;
  final Function setNavBarVisibility;

  // FavoritesPage Constructor
  SavedArticlesPage(this.model, this.setNavBarVisibility);

  @override // create state
  _SavedArticlesPage createState() => _SavedArticlesPage();
}

class _SavedArticlesPage extends State<SavedArticlesPage>
    with TickerProviderStateMixin {
  // Class Attributes

  // animated list global key
  GlobalKey<AnimatedListState> _listkey;
  // restore button animation controller
  AnimationController _restoreAnimController;
  // scroll controller
  ScrollController _hideButtonController;
  // reference to last article removed
  Article _lastRemoved;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // restore button animation controller
    _restoreAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    // crate button scroll controller
    _hideButtonController = new ScrollController();
    _listkey = GlobalKey<AnimatedListState>();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // build dismissible widget
  Widget _buildDismissibleListTile(Article article, int index) {
    return Dismissible(
      key: ObjectKey(article),
      background: SlideRightBackground(),
      secondaryBackground: SlideLeftBackground(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await DBservice.deleteArticle(article.url);
          _removeItem(index);
          _restoreAnimController.forward();
          _lastRemoved = article;
          widget.model.callNotifyListeners();
        }
      },
      confirmDismiss: (direction) {
        if (direction == DismissDirection.endToStart) {
          return Future.value(true);
        } else if (direction == DismissDirection.startToEnd) {
          String shareStr = 'Check out this article:\n';
          Share.share(shareStr + article.url);
        }
        return Future.value(false);
      },
      // ListTile
      child: SavedArticleListTile(article, index),
    );
  }

  // build animated list
  Widget _buildAnimatedList(List<Article> articles) {
    Tween tween = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
    return AnimatedList(
        key: _listkey,
        controller: _hideButtonController,
        physics: ScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        shrinkWrap: true,
        initialItemCount: articles.length,
        itemBuilder: (context, index, animation) {
          return SlideTransition(
            position: tween.animate(animation),
            child: _buildDismissibleListTile(articles[index], index),
          );
        });
  }

  // build actions widget method
  List<Widget> _buildActions() {
    var actions = <Widget>[
      ScaleTransition(
          child: IconButton(
            tooltip: 'Restore',
            // Icon Button to open search dialog
            icon: Icon(
              Icons.restore,
              size: 25,
            ),
            // show search dialog when pressed
            onPressed: () {
              // insert item to animated list
              _insertItem();
              _restoreAnimController.reverse();
            },
          ),
          scale: CurvedAnimation(
              parent: _restoreAnimController,
              curve: Interval(0, 1.0, curve: Curves.easeOut))),
      IconButton(
        tooltip: 'Search',
        // Icon Button to open search dialog
        icon: Icon(
          Icons.search,
          size: 25,
        ),
        // show search dialog when pressed
        onPressed: () {
          Navigator.pushNamed(context, '/custom_search');
        },
      ),
      IconButton(
          tooltip: 'Settings',
          icon: Icon(
            Icons.settings,
            size: 25,
          ),
          onPressed: () => Navigator.pushNamed(context, '/settings'))
    ];
    return actions;
  }

  // remove item from favorites animated list
  void _removeItem(int index) {
    _listkey.currentState
        .removeItem(index, (context, animation) => Container());
  }

  // insert item to favorites animated list
  void _insertItem() async {
    bool complete = await DBservice.addArticle(_lastRemoved);
    if (!complete) {
      return;
    }
    List<Article> articles = await DBservice.getArticles();
    if (_listkey.currentState != null)
      _listkey.currentState.insertItem(articles.length - 1);

    // insert item from empty list
    // call setState to notify UI change
    if (articles.length == 1) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0))),
          title: AppBarTitle('Saved'),
          // app bar action buttons
          actions: _buildActions(),
        ),
        body: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, MainModel model) {
          List<Article> articles = DBservice.savedArticles;
          if (articles != null && articles.isNotEmpty) {
            return _buildAnimatedList(articles);
          } else {
            return EmptyPage();
          }
        }));
  }
}

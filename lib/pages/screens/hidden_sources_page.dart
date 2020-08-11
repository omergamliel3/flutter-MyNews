import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/services/prefs_service.dart';

import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

// Hidden Sources Page Class

class HiddenSourcesPage extends StatefulWidget {
  @override
  _HiddenSourcesPageState createState() => _HiddenSourcesPageState();
}

class _HiddenSourcesPageState extends State<HiddenSourcesPage> {
  // Class Attributes
  List<String> hiddenSources;
  GlobalKey<AnimatedListState> _listKey;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    // get hidden sources from prefs service
    hiddenSources = Prefs.getHiddenSources();
    // init global keys
    _listKey = GlobalKey<AnimatedListState>();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
  }

  // return scaffold body widget
  Widget _buildScaffoldBody() {
    if (hiddenSources != null && hiddenSources.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: AnimatedList(
          key: _listKey,
          physics: ScrollPhysics(),
          initialItemCount: hiddenSources.length,
          itemBuilder: (BuildContext context, int index, Animation animation) {
            return FadeTransition(
                opacity: animation,
                child: _buildHiddenSourceCard(hiddenSources[index], index));
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 40),
        alignment: Alignment.topCenter,
        child: Text(
          'You haven\'t hidden any sources',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }
  }

  // build hidden source card widget
  Widget _buildHiddenSourceCard(String source, [int index]) {
    return Card(
      child: ListTile(
        title: Text(source),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: () {
            if (index != null) _removeItem(index);
          },
          tooltip: 'Remove',
        ),
      ),
    );
  }

  // remove item to hidden sources animated list
  void _removeItem(int index) async {
    // removed item from hidden sources list
    String removedItem = hiddenSources.removeAt(index);

    // remove item from animated list, trigger animation
    _listKey.currentState.removeItem(
        index,
        (context, animation) => FadeTransition(
              opacity: animation,
              child: _buildHiddenSourceCard(removedItem),
            ));

    // remove hidden source from prefs service
    Prefs.removeHiddenSource(MainModel.of(context), removedItem);

    // trigger snackbar
    _showSnackBar(removedItem, index);

    await Future.delayed(Duration(milliseconds: 500));
    if (hiddenSources.isEmpty) {
      setState(() {});
    }
  }

  // insert item to hidden sources animated list
  void _insertItem(String source, int index) {
    // insert item to animated list, trigger animation
    _listKey.currentState.insertItem(index);
    // insert local hidden sources list
    hiddenSources.insert(index, source);
    // add hidden source to prefs service
    Prefs.addHiddenSource(source, MainModel.of(context));
  }

  // show snack bar method
  void _showSnackBar(String source, int index) {
    var snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 3000),
        content: Text(
          'Restore $source',
        ),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              if (hiddenSources.isEmpty) {
                setState(() {
                  hiddenSources.add(source);
                });
              } else {
                _insertItem(source, index);
              }
            }));

    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AppBarTitle('Sources you\'ve hidden'),
      ),
      body: _buildScaffoldBody(),
    );
  }
}

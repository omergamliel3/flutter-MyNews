import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:MyNews/widgets/views/news_page.dart';
import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

class SearchPage extends StatelessWidget {
  // Class Attributes
  final String title;
  final MainModel model;
  final int prevIndexPage;
  // SearchPage Constructor
  SearchPage(this.title, this.model, this.prevIndexPage);

  @override
  Widget build(BuildContext context) {
    // Class Attributes
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () {
              // set page index back to prev index page
              model.setPageIndex(prevIndexPage);
              return Future.value(true);
            },
            child: Scaffold(
              appBar: AppBar(
                title: AppBarTitle(title),
                actions: <Widget>[
                  // search icon button to open SearchDialog method
                  IconButton(
                      tooltip: 'Search',
                      icon: Icon(Icons.search),
                      onPressed: () {
                        Navigator.pushNamed(context, '/custom_search');
                      })
                ],
              ),
              // NewsPage widget to build news card widgets
              body: NewsPage(
                model: model,
                saveSearch: true,
                search: title,
              ),
            ),
          ),
        );
      },
    );
  }
}

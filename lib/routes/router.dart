import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:MyNews/pages/screens/index.dart';
import 'package:MyNews/scoped-models/main.dart';

class Router {
  final Function _changeState;
  MainModel _model;
  Router(this._changeState);

  // dynamic routes
  Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      // loading route
      case '/':
        return PageTransition(
            child: LoadingScreen(_model),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50));
        break;
      // main route
      case '/main':
        return PageTransition(
            child: MainPage(_model),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
      // settings route
      case '/settings':
        return PageTransition(
            child: SettingsPage(_model, _changeState),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 150));
        break;
      // search route
      case '/search':
        String search;
        search = settings.name.split('/')[2].toString();
        int prevPageIndex = _model.pageIndex;
        // set page index to search page index
        //_model.setPageIndex(pageIndexMap['Search']);
        return PageTransition(
            child: SearchPage(search, _model, prevPageIndex),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
        break;
      // custom search route
      case '/custom_search':
        return PageTransition(
            child: CustomSearch(_model),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
        break;
      case '/hidden_sources':
        return PageTransition(
            child: HiddenSourcesPage(),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 150));
        break;
      // default route
      default:
        return MaterialPageRoute(
            builder: (BuildContext context) => MainPage(_model));
    }
  }
}

import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:MyNews/pages/screens/index.dart';

class Router {
  final Function _changeState;
  Router(this._changeState);

  // dynamic routes
  Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      // loading route
      case '/':
        return PageTransition(
            child: LoadingScreen(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50));
        break;
      // main route
      case '/main':
        return PageTransition(
            child: MainPage(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
      // settings route
      case '/settings':
        return PageTransition(
            child: SettingsPage(_changeState),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 150));
        break;
      // search route
      case '/search':
        var search = settings.arguments as Map<String, String>;
        return PageTransition(
            child: SearchPage(search['search']),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
        break;
      // custom search route
      case '/custom_search':
        return PageTransition(
            child: CustomSearch(),
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
        return MaterialPageRoute(builder: (BuildContext context) => MainPage());
    }
  }
}

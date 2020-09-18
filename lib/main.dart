import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter/foundation.dart' as foundation;
import 'package:scoped_model/scoped_model.dart';
import 'package:device_preview/device_preview.dart';
import 'package:page_transition/page_transition.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/pages/screens/loading_screen.dart';
import 'package:MyNews/pages/main/main_page.dart';
import 'package:MyNews/pages/screens/custom_search.dart';
import 'package:MyNews/pages/screens/search_page.dart';
import 'package:MyNews/pages/screens/settings_page.dart';
import 'package:MyNews/pages/screens/hidden_sources_page.dart';

import 'package:MyNews/shared/adaptive_theme.dart';
import 'package:MyNews/shared/dark_theme.dart';
import 'package:MyNews/shared/global_values.dart';

void main() {
  // Main Function
  runApp(DevicePreview(
      enabled: !foundation.kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Class Attributes
  final MainModel _model = MainModel();
  Future<void> future;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    services.SystemChrome.setPreferredOrientations([
      services.DeviceOrientation.portraitUp,
      services.DeviceOrientation.portraitDown
    ]);
    // init theme data
    future = _model.initThemeData();
    super.initState();
  }

  // setState the entire app
  void changeState() {
    setState(() {});
  }

  // dynamic routes
  Route<dynamic> _routes(RouteSettings settings) {
    // extract the route name from the settings.name
    String route = settings.name.split('/')[1].toString();

    switch (route) {
      // main route
      case 'main':
        return PageTransition(
            child: MainPage(_model, changeState),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
      // settings route
      case 'settings':
        return PageTransition(
            child: SettingsPage(_model, changeState),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 150));
        break;
      // search route
      case 'search':
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
      case 'custom_search':
        return PageTransition(
            child: CustomSearch(_model),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 150));
        break;
      case 'hidden_sources':
        return PageTransition(
            child: HiddenSourcesPage(),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 150));
        break;
      // default route
      default:
        return MaterialPageRoute(
            builder: (BuildContext context) => MainPage(_model, changeState));
    }
  }

  // Unknown Route
  Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => MainPage(_model, changeState));
  }

  // handle future builder error
  _handleSnapshotError(AsyncSnapshot<void> snapshot) {
    return MaterialApp(
      title: appName,
      builder: (context, child) {
        return Scaffold(
          body: Text(
            'An error has been accoured. Please re-open the app',
            style: TextStyle(fontSize: 30),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              _handleSnapshotError(snapshot);
            }
            return ScopedModel<MainModel>(
                model: _model,
                child: MaterialApp(
                  title: appName,
                  locale: DevicePreview.of(context).locale,
                  builder: DevicePreview.appBuilder,
                  theme: getAndroidThemeData(_model.selectedAccentColorIndex),
                  darkTheme: darkThemeData(_model.selectedAccentColorIndex),
                  themeMode: _model.isDark ? ThemeMode.dark : ThemeMode.light,
                  routes: {
                    '/': (BuildContext context) => LoadingScreen(_model),
                    '/main': (BuildContext context) =>
                        MainPage(_model, changeState)
                  },
                  onGenerateRoute: _routes,
                  onUnknownRoute: _unknownRoute,
                  debugShowCheckedModeBanner: false,
                ));
          } else
            return Container();
        });
  }
}

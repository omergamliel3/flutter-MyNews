import 'package:MyNews/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter/foundation.dart' as foundation;

import 'package:scoped_model/scoped_model.dart';
import 'package:device_preview/device_preview.dart';

import 'package:MyNews/scoped-models/main.dart';

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
  Future<void> loadThemeData;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    services.SystemChrome.setPreferredOrientations([
      services.DeviceOrientation.portraitUp,
      services.DeviceOrientation.portraitDown
    ]);
    // init theme data
    loadThemeData = _model.initThemeData();
    super.initState();
  }

  // setState the entire app
  void changeState() {
    setState(() {});
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
        future: loadThemeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              _handleSnapshotError(snapshot);
            }
            var router = Router(changeState);
            return ScopedModel<MainModel>(
                model: _model,
                child: MaterialApp(
                  title: appName,
                  locale: DevicePreview.of(context).locale,
                  builder: DevicePreview.appBuilder,
                  theme: getAndroidThemeData(_model.selectedAccentColorIndex),
                  darkTheme: darkThemeData(_model.selectedAccentColorIndex),
                  themeMode: _model.isDark ? ThemeMode.dark : ThemeMode.light,
                  onGenerateRoute: router.routes,
                  debugShowCheckedModeBanner: false,
                ));
          } else
            return Container();
        });
  }
}

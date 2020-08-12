import 'dart:async';

import 'package:MyNews/services/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as scheduler;
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:android_intent/android_intent.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/services/custom_services.dart';
import 'package:MyNews/services/db_service.dart';
import 'package:MyNews/services/notifications_service.dart';
//import 'package:MyNews/services/admob_service.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();

  final MainModel _model;

  LoadingScreen(this._model);
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  AnimationController _logoAnimationController;
  Animation _logoAnimation;
  //bool _isDialogOpen = false;

  @override
  void initState() {
    // set the logo animation controller
    _logoAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700),
        reverseDuration: Duration(milliseconds: 700));

    // set the logo animation
    // animate between values with Tween animation
    _logoAnimation = Tween(begin: 200.0, end: 210.0).animate(CurvedAnimation(
        curve: Curves.linear, parent: _logoAnimationController));

    // add listener to the animation controller
    _logoAnimationController.addStatusListener((AnimationStatus status) {
      // when status complete animation reverse
      if (status == AnimationStatus.completed) {
        _logoAnimationController.reverse();
        // when status dismissed animation forward
      } else if (status == AnimationStatus.dismissed) {
        _logoAnimationController.forward();
      }
    });
    // forward the animation
    _logoAnimationController.forward();

    // We require the initializers to run after the loading screen is rendered
    scheduler.SchedulerBinding.instance.addPostFrameCallback((_) {
      runInitTasks();
    });

    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  /// This method calls the initializers and once they complete redirects to main page
  Future runInitTasks(
      {bool allowNoConnectivity = false, bool skipLocation = false}) async {
    // checks for internet connectivity
    bool connectivity = await Connectivity.internetConnectivity();
    // if connectivity is false show dialog and stops the function
    if (!allowNoConnectivity) {
      if (!connectivity) {
        _handleNoConnectivity();
        return;
      }
    }

    if (!skipLocation) {
      // get device location / last location
      bool location = await widget._model.fetchLocation();
      // handle no location
      if (!location) {
        _handleNoLocation();
        return;
      }
    }

    // init notifications
    Notifications.initNotifications();

    // init app data (prefs and local)
    await widget._model.initAppData();

    // init db service
    bool initDB = await DBservice.asyncInitDB();
    // close the app if failed to init db
    if (!initDB) {
      SystemNavigator.pop();
    }

    // init prefs service
    Prefs.initPrefs();

    // fetch temp news data from db
    await widget._model.fetchHeadlinesData(connectivity);
    await widget._model.fetchFollowingData(connectivity);

    // init admob serivce
    //AdMobHelper.initialiseAdMob();

    // show no connectivity toast
    if (!connectivity) {
      Fluttertoast.showToast(
        msg: 'There is no internet connection',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }

    // navigate main page
    Navigator.of(context).pushReplacementNamed('/main');
  }

  // handle no internet connection
  void _handleNoConnectivity() {
    bool isDialogOpen = false;

    Fluttertoast.showToast(
      msg: 'Please connect your device to wifi network or mobile data',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    // Invoke internetConnectivity method every 1 second
    Timer.periodic(Duration(seconds: 1), (timer) async {
      bool connectivity = await Connectivity.internetConnectivity();
      // if connectivity is true cancel timer and call runInitTasks
      if (connectivity) {
        runInitTasks();
        // pop from dialog if open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        timer.cancel();
      }

      if (timer.tick > 5) {
        // allow app launch only if disableLocation value true or lastLocation is saved
        // otherwise the app is opened for the first time and must have connectivity
        bool locationDisable =
            widget._model.sharedPreferences.getBool('disableLocation') ?? false;
        bool locationSaved =
            widget._model.sharedPreferences.getString('lastLocation') != null;

        // app launched before
        if (locationDisable || locationSaved) {
          // launch app with no internet
          runInitTasks(allowNoConnectivity: true);
          timer.cancel();
        }
        // app launch for the first time
        else if (!isDialogOpen) {
          // show dialog
          isDialogOpen = true;
          _showNoConnectivityDialog();
        }
      }
    });
  }

  // handle no locatiom dialog
  void _handleNoLocation() async {
    // show enable location toast
    Fluttertoast.showToast(
      msg: 'Please enable location service',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    bool location = false;
    bool dialogOpen = false;
    int timer = 0;

    // invoke loop every 1 seconds until success fetch location
    while (!location) {
      await Future.delayed(Duration(seconds: 1));
      timer++;

      // show dialog after 8 seconds
      if (timer > 8 && !dialogOpen) {
        dialogOpen = true;
        _showNoLocationDialog();
      }
      // fetch location
      location = await widget._model.fetchLocation();
    }
    // pop from dialog if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // run Init Tasks with skip location
    runInitTasks(skipLocation: true);
  }

  // show no connectivity dialog
  void _showNoConnectivityDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text('No internet connection'),
            content: Text(
                'You must have internet connection when launch the app for the first time'),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text(
                    'WIRELESS SETTINGS',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    final AndroidIntent intent = new AndroidIntent(
                      action: 'android.settings.WIRELESS_SETTINGS',
                    );
                    intent.launch();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // show no location dialog
  void _showNoLocationDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text('Can\'t get your location'),
            content: Text(
                'We need your location one time only, to determine your country and show you local news'),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text(
                    'LOCATION SETTINGS',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    final AndroidIntent intent = new AndroidIntent(
                      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
                    );
                    intent.launch();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InkWell(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: widget._model.isDark ? Colors.black : Colors.white),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 50),
                    child: AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Image.asset(
                          'Assets/images/loading_screen_logo.png',
                          fit: BoxFit.cover,
                          height: _logoAnimation.value,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Just a few seconds and we are ready to go...'
                          .toUpperCase(),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

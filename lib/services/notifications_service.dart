import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Notifications class
class Notifications {
  /// init notifications
  static void initNotifications() async {
    // prefs instace
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // return if notifications allready have been initialised
    if (prefs.getBool('Notifications') != null) return;

    // initialise the plugin
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // setRepeatNotifications
    _setRepeatNotifications(flutterLocalNotificationsPlugin, prefs);
  }

  /// set daily news reminder notification
  static Future _setRepeatNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      SharedPreferences prefs) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Repeating reminder',
        'Daily news reminder',
        'When device is unlocked, show notifications as a banner acroos the top of the screen',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    // set daily notifications at 10, 16, 20
    int hour;
    for (var i = 0; i < 3; i++) {
      if (i == 0) {
        // set morning notification (10)
        hour = 10;
      } else if (i == 1) {
        // set afternoon notification (16)
        hour = 16;
      } else if (i == 2) {
        // set evening notification (20)
        hour = 20;
      }
      await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Daily news',
        'Check out latest local, world and following headlines',
        Time(hour, 0, 0),
        platformChannelSpecifics,
      );
    }

    // set Notifications bool to true
    prefs.setBool('Notifications', true);
  }
}

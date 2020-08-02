import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// Connectivity class
class Connectivity {
  /// checks for internet connectivity
  /// return true for connection, false for no connection
  static Future<bool> internetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}

// Language class
class LanguageHelper {
  /// identify language with regular expression, from a given text argument.
  /// the text argument should be the article title
  static String identifyLanguageWithRegEx(String text) {
    if (text == null) {
      return 'rtl';
    }
    // take a word from text
    String word = text.split(' ')[0];
    if (word == null) return 'rtl';
    // RTL languages RegExp
    RegExp hebrewRegExp = RegExp('[\u0590-\u05fe]');
    RegExp arabicRegExp = RegExp('[\u0600-۾]');
    // if word contains hebrew or arabic return rtl, else return ltr.
    if (word.contains(hebrewRegExp) || word.contains(arabicRegExp)) {
      return 'rtl';
    } else {
      return 'ltr';
    }
  }
}

// Calculate class
class Helpers {
  /// foramtting date to fit the news api http request formmat
  static String calculateDate(DateTime from, DateTime to) {
    // return api string formmat
    return '&from=' + from.toIso8601String() + '&to=' + to.toIso8601String();
  }
}

// Launch Url Helper class
class LaunchUrlHelper {
  /// launch simple url
  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

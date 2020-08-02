import 'package:timeago/timeago.dart' as timeago;

// implement CustomString method extentions to String class

extension CustomString on String {
  /// return month name string with a given month integer string
  String getMonth() {
    String month = '';
    switch (this) {
      case '01':
        month = "January";
        break;
      case '02':
        month = "February";
        break;
      case '03':
        month = "March";
        break;
      case '04':
        month = "April";
        break;
      case '05':
        month = "May";
        break;
      case '06':
        month = "June";
        break;
      case '07':
        month = "July";
        break;
      case '08':
        month = "August";
        break;
      case '09':
        month = "September";
        break;
      case '10':
        month = "October";
        break;
      case '11':
        month = "November";
        break;
      case '12':
        month = "December";
        break;
    }
    return month;
  }

  /// takes a date and covnert the time to: today / yesterday / Month + day
  String getTimeAgo() {
    try {
      final time = DateTime.parse(this);
      return timeago.format(time);
    } catch (e) {
      print(e);
      final time = DateTime.parse(this.split('\"')[1]);
      return timeago.format(time);
    }
  }

  /// capitalize first char
  String upperCaseFirstChar() {
    // ensure trim and lower case
    String str = this.trim().toLowerCase();
    // Upper case first char
    str = str[0].toUpperCase() + str.substring(1, str.length);
    return str;
  }
}

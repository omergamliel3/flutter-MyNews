import 'package:flutter_email_sender/flutter_email_sender.dart';

// Mail Helper class
class MailHelper {
  static const String appMail = 'mynewsapp38@gmail.com';

  /// set feedback mail using flutter email sender plugin
  static void sendMail() async {
    final Email email = Email(
      subject: 'MyNews App feedback',
      recipients: [appMail],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  /// set issue mail using flutter email sender plugin
  static void sentIssue({String screenshotPath = ''}) async {
    final Email email = Email(
      subject: 'MyNews App issue',
      recipients: [appMail],
      attachmentPaths: [screenshotPath] ?? null,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}

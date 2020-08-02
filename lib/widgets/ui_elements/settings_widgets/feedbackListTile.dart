import 'package:flutter/material.dart';

import 'package:MyNews/services/mail_service.dart';

class FeedBackListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.feedback,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Give Us Feedback'),
      trailing: Icon(
        Icons.call_made,
      ),
      onTap: () {
        MailHelper.sendMail();
      },
    );
  }
}

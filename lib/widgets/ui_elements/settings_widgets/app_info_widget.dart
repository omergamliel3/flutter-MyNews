import 'package:flutter/material.dart';

import 'package:MyNews/shared/global_values.dart';

class AppInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).accentColor,
      ),
      title: Text('About'),
      // trailing: Icon(
      //   Icons.call_made,
      // ),
      onTap: () {
        showAboutDialog(
            context: context,
            applicationName: appName,
            applicationVersion: appVersion,
            applicationIcon: Image.asset(
              'Assets/images/loading_screen_logo.png',
              height: 50,
              width: 50,
            ),
            children: [
              Text(
                'Personal news app based on NewsAPI.org\n\nDeveloped by Omer Gamliel',
              )
            ]);
      },
    );
  }
}

import 'package:flutter/material.dart';

class HiddenSourcesListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.remove_circle, color: Theme.of(context).accentColor),
      title: Text('Hidden Sources'),
      trailing: Icon(Icons.call_made),
      onTap: () {
        // navigate hidden sources page
        Navigator.pushNamed(context, '/hidden_sources');
      },
    );
  }
}

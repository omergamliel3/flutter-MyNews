import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class PrivateSessionWidget extends StatefulWidget {
  @override
  _PrivateSessionWidgetState createState() => _PrivateSessionWidgetState();
}

class _PrivateSessionWidgetState extends State<PrivateSessionWidget> {
  MainModel _model;

  @override
  void didChangeDependencies() {
    _model = MainModel.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          _model.setPrivateSession(!_model.privateSession);
        });
      },
      leading: Icon(
        Icons.security,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Private Search'),
      trailing: Switch(
        value: _model.privateSession,
        onChanged: (value) {
          setState(() {
            _model.setPrivateSession(value);
          });
        },
        activeColor: Theme.of(context).accentColor,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RemoveLocationWidget extends StatefulWidget {
  // remove location dialog
  @override
  _RemoveLocationWidgetState createState() => _RemoveLocationWidgetState();

  final MainModel _model;
  RemoveLocationWidget(this._model);
}

class _RemoveLocationWidgetState extends State<RemoveLocationWidget> {
  bool disableLocation;
  @override
  void initState() {
    disableLocation = widget._model.disableLocation;
    super.initState();
  }

  // update location dialog

  void _showUpdateLocationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AbsorbPointer(
            child: AlertDialog(
                // alert dialog widget
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                title: Text('UPDATE YOUR LOCATION...'),
                content: SingleChildScrollView(
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )))),
          );
        });
  }

  void _onChanged(bool value) async {
    // update switch value state
    setState(() {
      disableLocation = value;
    });
    // set disable location to new value
    widget._model.setDisableLocation(disableLocation);
    // if disable location is false, fetch location
    if (!disableLocation) {
      _showUpdateLocationDialog();
      bool fetchLocation = await widget._model.fetchLocation(refetch: true);
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      if (fetchLocation) {
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg: 'Update your location to ${widget._model.searchCountry}');
      } else {
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg: 'Failed to update your location');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: Text('Disable Location'),
        secondary: Icon(
          Icons.location_off,
          color: Theme.of(context).accentColor,
        ),
        activeColor: Theme.of(context).accentColor,
        value: disableLocation,
        onChanged: _onChanged);
  }
}

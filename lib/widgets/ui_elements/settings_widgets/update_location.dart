import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:fluttertoast/fluttertoast.dart';

class UpdatelocationWidget extends StatelessWidget {
  // update location dialog
  void _showUpdateLocationDialog(BuildContext context) {
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

  void fetchLocation(BuildContext context) async {
    MainModel model = MainModel.of(context);
    _showUpdateLocationDialog(context);
    bool location = await model.fetchLocation(refetch: true);
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();

    String message;
    if (location) {
      message = 'Location has been updated to ${model.searchCountry}';
    } else {
      message = 'Failed to update location';
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.location_searching,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Update Location'),
      onTap: () {
        if (MainModel.of(context).disableLocation) {
          Fluttertoast.showToast(
            msg: 'Disable Location is on',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          fetchLocation(context);
        }
      },
    );
  }
}

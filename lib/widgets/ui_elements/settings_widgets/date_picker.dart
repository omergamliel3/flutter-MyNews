import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

enum DateMode { FromDate, ToDate }

class DatePicker extends StatelessWidget {
  final MainModel _model;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  DatePicker(this._model, this._scaffoldKey);

  // select date method
  Future<Null> _selectDate(BuildContext context, {DateMode dateMode}) async {
    DateTime picked;
    DateTime fromDate = _model.fromDate;
    DateTime toDate = _model.toDate;
    if (dateMode == DateMode.FromDate) {
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      picked = await showDatePicker(
          context: context,
          initialDate: fromDate,
          firstDate: DateTime.now().subtract(Duration(days: 31)),
          lastDate: yesterday);
      if (picked != null && picked != fromDate) {
        if (picked.isBefore(toDate)) {
          // call setFromDate to update from date
          _model.setFromDate(picked);
        } else {
          showInvalidDateSnackBar(context,
              text: 'From Date must be before To Date');
        }
      }
      // ToDate picker
    } else if (dateMode == DateMode.ToDate) {
      picked = await showDatePicker(
          context: context,
          initialDate: toDate,
          firstDate: DateTime(2010, 1),
          lastDate: DateTime.now());
      if (picked != null && picked != toDate) {
        if (picked.isAfter(fromDate)) {
          // call setToDate to update to date
          _model.setToDate(picked);
        } else {
          showInvalidDateSnackBar(context,
              text: 'To Date must be after From Date');
        }
      }
    }
  }

  // show invalid date snackbar method
  showInvalidDateSnackBar(BuildContext context, {@required String text}) {
    Color textColor = _model.isDark ? Theme.of(context).accentColor : null;
    SnackBar snackBar = SnackBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).primaryColor
          : null,
      duration: Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    bool disablePicker = _model.searchDateMode != SearchDateMode.Custom;
    Widget fromDateText =
        Text(_model.fromDate.toIso8601String().substring(0, 10));
    Widget toDateText = Text(_model.toDate.toIso8601String().substring(0, 10));

    return AbsorbPointer(
      absorbing: disablePicker,
      child: Column(
        children: <Widget>[
          ListTile(
              leading:
                  Icon(Icons.date_range, color: Theme.of(context).accentColor),
              title: Text('Search From Date'),
              trailing: fromDateText,
              onTap: () {
                _selectDate(context, dateMode: DateMode.FromDate);
              }),
          ListTile(
            leading:
                Icon(Icons.date_range, color: Theme.of(context).accentColor),
            title: Text('Search To Date'),
            trailing: toDateText,
            onTap: () {
              _selectDate(context, dateMode: DateMode.ToDate);
            },
          ),
        ],
      ),
    );
  }
}

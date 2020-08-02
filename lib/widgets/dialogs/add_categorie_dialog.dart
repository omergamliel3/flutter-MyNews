import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class AddCategorieDialog extends StatefulWidget {
  // Class Attributes
  final Function addLocalCategorie;
  final MainModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;

  // Constructor
  AddCategorieDialog({this.addLocalCategorie, this.model, this.scaffoldKey});

  @override
  _AddCategorieDialogState createState() => _AddCategorieDialogState();
}

class _AddCategorieDialogState extends State<AddCategorieDialog> {
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // FormField value
  String savedValue = '';

  // submit method, called when onPressed 'OK' Button
  void _submit() {
    widget.model
        .addCategories(savedValue.trim(), widget.addLocalCategorie)
        .then((_) {
      showSnackBar(savedValue);
    });

    Navigator.of(context).pop();
  }

  // _future method to await function and _formKey save to complete
  Future<bool> _future() {
    _formKey.currentState.save();

    return Future.value(true);
  }

  // show snackbar in saffoldKey method, called when categorie added
  void showSnackBar(String savedValue) {
    Color textColor =
        widget.model.isDark ? Theme.of(context).accentColor : Colors.white;
    // snackBar
    SnackBar snackBar = SnackBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).primaryColor
          : null,
      duration: Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(
        '$savedValue added to Following',
        style: TextStyle(color: textColor),
      ),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).accentColor;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Text(
        'ADD TOPIC',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentColor)),
                    hintText: 'Enter Topic'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Topic is empty';
                  }
                  for (int i = 0; i < value.length; i++) {
                    if (!value[i].contains(RegExp(r'[a-zA-Z0-9 ]'))) {
                      return 'Only english letters and numbers are valid';
                    }
                  }

                  return null;
                },
                onSaved: (value) {
                  savedValue = value;
                },
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          // Go back button
          child: Text(
            'BACK',
            style: TextStyle(color: accentColor),
          ),
          onPressed: () {
            // Go back when pressed
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          // OK back button
          child: Text(
            'ADD',
            style: TextStyle(color: accentColor),
          ),
          onPressed: () {
            // submit form if validate
            if (_formKey.currentState.validate()) {
              _future().then((_) {
                _submit();
              });
            }
          },
        )
      ],
    );
  }
}

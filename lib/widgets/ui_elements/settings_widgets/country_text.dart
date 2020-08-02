import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

class CountryText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainModel _model = MainModel.of(context);
    // build custom search widget method
    String country = _model.searchCountry != null
        ? _model.searchCountry.toUpperCase()
        : 'DISABLE';
    Color accentColor = Theme.of(context).accentColor;
    return ListTile(
        leading: Icon(
          Icons.flag,
          color: accentColor,
        ),
        title: Text('Country'),
        trailing: Text(
          '$country  ',
          style: TextStyle(fontWeight: FontWeight.normal),
        ));
  }
}

import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/shared/global_values.dart';

class ColorPicker extends StatefulWidget {
  @override
  _ColorPickerState createState() => _ColorPickerState();

  final MainModel model;
  final Function changeAppState;

  ColorPicker(this.model, this.changeAppState);
}

class _ColorPickerState extends State<ColorPicker> {
  // selected color index value
  int selectedColorIndex;

  // alert dialog widget
  AlertDialog _colorPickerDialog() {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        title: Text('SELECT COLOR'),
        actions: <Widget>[
          FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              onPressed: () {
                selectedColorIndex = widget.model.selectedAccentColorIndex;
                Navigator.of(context).pop();
              }),
          FlatButton(
            child: Text(
              'SUBMIT',
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            onPressed: () {
              submit();
              Navigator.of(context).pop();
            },
          )
        ],
        content: _buildColors());
  }

  // build color
  Widget _buildColors() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceBetween,
            children: List.generate(
                accentColors.length,
                (index) => InkWell(
                      borderRadius: BorderRadius.circular(100.0),
                      onTap: () {
                        setState(() {
                          selectedColorIndex = index;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            elevation: 8.0,
                            height: 33,
                            minWidth: 33,
                            color: accentColors[index],
                            onPressed: () {},
                          ),
                          AnimatedOpacity(
                            opacity: selectedColorIndex == index ? 1 : 0,
                            duration: Duration(milliseconds: 300),
                            child: Icon(Icons.check, color: Colors.black),
                          )
                        ],
                      ),
                    )),
          ),
        );
      },
    );
  }

  // submit color function
  void submit() {
    if (widget.model.selectedAccentColorIndex == selectedColorIndex) return;
    // set selected accent color index in model
    widget.model.setSelectedAccentColorIndex(selectedColorIndex);
    // call set state from main to rebuild the app with new accent color
    widget.changeAppState();
  }

  @override
  Widget build(BuildContext context) {
    selectedColorIndex = widget.model.selectedAccentColorIndex;
    return ListTile(
      leading: Icon(
        Icons.color_lens,
        color: Theme.of(context).accentColor,
      ),
      title: Text('Accent Color'),
      trailing: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      onTap: () {
        showDialog(
            context: context, builder: (context) => _colorPickerDialog());
      },
    );
  }
}

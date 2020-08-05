import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/widgets/dialogs/add_categorie_dialog.dart';
import 'package:MyNews/widgets/dialogs/remove_dialog.dart';

import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

import 'package:MyNews/widgets/ui_elements/settings_widgets/color_picker.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/settings_text.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/country_text.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/update_location.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/disable_location_listTile.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/app_info_widget.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/delete_search_widget.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/private_session_widget.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/change_theme_widget.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/feedbackListTile.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/time_search_menu.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/date_picker.dart';
import 'package:MyNews/widgets/ui_elements/settings_widgets/restore_defaults_listTile.dart';

enum DateMode { FromDate, ToDate }

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();

  // Class Attributes
  final MainModel model;
  final Function changeState;
  //final Function navigateHomePage;

  // Constructor
  SettingsPage(this.model, this.changeState);
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  // Class Attributes
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaved = false;
  // FormFields List of FocusNode
  List<FocusNode> _formFieldfocusNodeList = [];
  // TextEditingController list
  List<TextEditingController> _textEditingControllerList = [];
  // expanded list
  List<bool> _expandedList;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // revrieve date times from model
    _expandedList = [];

    int navBarLength = widget.model.getfollowingTopicsList.length;
    // Generate FocusNode List with the given ButtonNavBarList length
    _formFieldfocusNodeList = List.generate(navBarLength, (index) {
      return FocusNode();
    });

    // Generate TextEditingController list
    _textEditingControllerList = List.generate(navBarLength, (index) {
      return TextEditingController();
    });

    for (var i = 0; i < _textEditingControllerList.length; i++) {
      _textEditingControllerList[i].text =
          widget.model.getfollowingTopicsList[i];
    }

    // set state when focus is changed to change the style color
    _formFieldfocusNodeList.forEach((element) {
      element.addListener(() {
        setState(() {});
      });
    });
    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    _formFieldfocusNodeList.forEach((element) {
      element.dispose();
    });
    _textEditingControllerList.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  // UnFocusScope Method, creates a new FocusNode
  void _unFocusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // index NavBar TextField Widget method
  Widget _buildNavBarTextField(int index) {
    // set TextField Attributes
    FocusNode focusNode = _formFieldfocusNodeList[index];
    //Color iconColor = focusNode.hasFocus ? Theme.of(context).accentColor : null;
    //Widget icon =
    //Icon(widget.model.getNavBarIconDataList[index], color: iconColor);
    Color dynamicColor = widget.model.isDark ? Colors.grey : Colors.black;

    // TextFormField Widget
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 5.0),
          // ensure visibile when focuse helper
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
              controller: _textEditingControllerList[index],
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              // field decoration
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 2)),
                border: UnderlineInputBorder(),
                //labelText: 'NavBar${index + 1}',
                labelStyle: TextStyle(color: dynamicColor),
                hintText: 'Enter Topic ${index + 1}',
              ),
              keyboardType: TextInputType.text,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Topic ${index + 1} is required';
                }
                for (int i = 0; i < value.length; i++) {
                  if (!value[i].contains(RegExp(r'[a-zA-Z0-9 ]'))) {
                    return 'Only english letters and numbers are valid';
                  }
                }

                return null;
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          padding: EdgeInsets.only(right: 5.0),
          alignment: Alignment.centerRight,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            widget.model.getfollowingTopicsList.length == 2
                ? Container()
                : FlatButton(
                    onPressed: () {
                      // show remove categorie dialog
                      _buildRemoveDialog(index);
                    },
                    child: Text(
                      'REMOVE',
                      style: TextStyle(color: Colors.red),
                    )),
            FlatButton(
                onPressed: () {
                  // submit form if text value is changed
                  String strButtonNavBar =
                      widget.model.getfollowingTopicsList[index];
                  String value = _textEditingControllerList[index].text;
                  if (value != strButtonNavBar && value != '') {
                    _isSaved = true;
                    widget.model.setButtonNavBar(index, value.trim());
                    // call submit form
                    _submitForm();
                  }
                },
                child: Text(
                  'SAVE',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ))
          ]),
        )
      ],
    );
  }

  // build expansion panel list
  Widget _buildExpansionPanelList() {
    List<String> navBarList = widget.model.getfollowingTopicsList;

    // Generate ExpansionPanel List with navBarList length
    List<ExpansionPanel> _expansionPanelList =
        List.generate(navBarList.length, (index) {
      _expandedList.add(false);
      return ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: _expandedList[index]
                  ? Text('Edit ${navBarList[index]}')
                  : Text(navBarList[index]),
            );
          },
          isExpanded: _expandedList[index],
          body: _buildNavBarTextField(index));
    });
    // return the ExpansionPanelList with _expansionPanelList as children
    return ExpansionPanelList(
      // changes the _expandedList index and setState when expand or collapse
      expansionCallback: (index, isExpanded) {
        setState(() {
          _expandedList[index] = !_expandedList[index];

          if (!isExpanded)
            for (var i = 0; i < _expandedList.length; i++) {
              if (i != index) _expandedList[i] = false;
            }
          if (!_expandedList[index]) _unFocusScope();
        });
      },
      children: _expansionPanelList,
    );
  }

  // edit categories Widget method
  Widget _editCategorie() {
    return ListTile(
      title: Text('Add to Following', style: TextStyle(fontSize: 16)),
      leading: Icon(
        Icons.add,
        color: Theme.of(context).accentColor,
      ),
      onTap: _buildAddDialog,
    );
  }

  // build settings card widget
  Widget _buildSettingsCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        margin: EdgeInsets.all(2),
        clipBehavior: Clip.hardEdge,
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Column(children: children),
      ),
    );
  }

  // build add dialog to add categorie to lists
  void _buildAddDialog() {
    // Close expansion
    for (var i = 0; i < _expandedList.length; i++) {
      _expandedList[i] = false;
    }
    Function submit = (String addedCategorie) {
      _formFieldfocusNodeList.add(FocusNode());
      _textEditingControllerList
          .add(TextEditingController(text: addedCategorie));
    };
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddCategorieDialog(
            addLocalCategorie: submit,
            model: widget.model,
            scaffoldKey: _scaffoldKey,
          );
        });
  }

  // build remove dialog method to remove last categorie from lists
  void _buildRemoveDialog(int categorieIndex) {
    String categorie = widget.model.getfollowingTopicsList[categorieIndex];
    // removeLocal function, called from dialog when remove categorie
    void removeLocal() {
      _formFieldfocusNodeList.removeAt(categorieIndex);
      _textEditingControllerList.removeAt(categorieIndex);
      _expandedList.removeAt(categorieIndex);
    }

    // show remove dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RemoveDialog(
            index: categorieIndex,
            categorie: categorie,
            model: widget.model,
            scaffoldKey: _scaffoldKey,
            removeLocal: removeLocal,
          );
        });
  }

  // delete saved search string from shared preferences
  void _deletePrefs() async {
    // reset locally
    _formFieldfocusNodeList.clear();
    _textEditingControllerList.clear();
    _expandedList.clear();
    int length = widget.model.getfollowingTopicsList.length;
    // generate _formFieldfocusNodeList
    _formFieldfocusNodeList = List.generate(length, (index) {
      return FocusNode();
    });
    _textEditingControllerList = List.generate(length, (index) {
      return TextEditingController();
    });
    _expandedList = List.generate(length, (index) {
      return false;
    });
    for (var i = 0; i < _textEditingControllerList.length; i++) {
      _textEditingControllerList[i].text =
          widget.model.getfollowingTopicsList[i];
    }
    // reset main model
    await widget.model.restoreToDefaults();
    await widget.model.initAppData();
    // setState the app
    widget.changeState();
    // pop from dialog
    Navigator.of(context).pop();
  }

  // submit form method
  void _submitForm() {
    // snackBar
    Color textColor =
        widget.model.isDark ? Theme.of(context).accentColor : null;
    SnackBar snackBar = SnackBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).primaryColor
          : null,
      duration: Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Topic saved',
        style: TextStyle(color: textColor),
      ),
    );
    // unfocus from the text field
    _unFocusScope();
    // Validate returns true if the form is valid, otherwise false.
    if (_formKey.currentState.validate()) {
      // show SnackBar at the buttom of the scaffold
      if (_isSaved) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
        _isSaved = false;
      }
    }
  }

  // build scaffold body widget method
  Widget _buildBody() {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return Container(
        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: true,
            child: Column(
              children: [
                // Following card
                SettingsText('Following'),
                SizedBox(
                  height: 10,
                ),
                _buildExpansionPanelList(),
                _buildSettingsCard([
                  _editCategorie(),
                ]),
                // Search card
                SettingsText('Search'),
                _buildSettingsCard([
                  CountryText(),
                  TimeSearchMenu(widget.model),
                  DatePicker(widget.model, _scaffoldKey),
                ]),
                SettingsText('Location'),
                _buildSettingsCard([
                  UpdatelocationWidget(),
                  RemoveLocationWidget(widget.model)
                ]),
                // Privacy card
                SettingsText('Privacy'),
                _buildSettingsCard([
                  DeleteSearchWidget(),
                  SizedBox(
                    height: 10,
                  ),
                  PrivateSessionWidget(),
                ]),
                // Restore card
                SettingsText('Restore'),
                _buildSettingsCard([RestoreDefaultsListTile(_deletePrefs)]),
                SettingsText('Customize'),
                _buildSettingsCard([
                  // Accent Color Picker
                  ColorPicker(widget.model, widget.changeState),
                  // Dark / Light mode button widget
                  ThemeListTile(widget.changeState, widget.model),
                ]),
                SettingsText('Info'),
                // info card
                _buildSettingsCard([FeedBackListTile(), AppInfoWidget()])
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _unFocusScope,
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: AppBarTitle('Settings'),
            ),
            key: _scaffoldKey,
            body: _buildBody(),
          ),
        ));
  }
}

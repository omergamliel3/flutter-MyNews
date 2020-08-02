import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/services/custom_services.dart';
import 'package:MyNews/services/prefs_service.dart';

class CustomSearch extends StatefulWidget {
  @override
  _CustomSearchState createState() => _CustomSearchState();

  final MainModel model;
  CustomSearch(this.model);
}

class _CustomSearchState extends State<CustomSearch>
    with TickerProviderStateMixin {
  bool showRecent = true;
  TextEditingController _textController = TextEditingController();
  AnimationController _clearAnimController;
  Future<List<String>> futureList;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Called when this object is inserted into the tree
  void initState() {
    _textController.addListener(() {
      final text = _textController.text;
      _textController.value = _textController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    _clearAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  // UnFocusScope Method, creates a new FocusNode
  void _unFocusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // build title textField widget method
  Widget _buildTitleTextField() {
    return TextField(
      controller: _textController,
      autofocus: true,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search for articles',
        hintStyle: TextStyle(fontSize: 16),
        border: InputBorder.none,
      ),
      onChanged: (_) {
        if (_textController.text == '') {
          if (_clearAnimController.status == AnimationStatus.completed) {
            _clearAnimController.reverse();
          }
        } else {
          if (_clearAnimController.status == AnimationStatus.dismissed) {
            _clearAnimController.forward();
          }
        }
        // check for suggestions
        setState(() {
          futureList = _getSuggestions();
        });
      },
      onSubmitted: (search) {
        _submitSearch(search);
      },
    );
  }

  // build suggestions widget method
  Widget _buildSuggestions() {
    // return empty container when private session is true
    if (widget.model.privateSession) {
      return Container();
    }
    //print('showRecent: $showRecent\nRecent Search Title: ${widget.model.savedSearchNewsTitle}');
    if (showRecent & widget.model.savedSearchNewsTitle.isNotEmpty) {
      showRecent = false;
      return _buildRecentSearch();
    } else
      return Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(5),
          child: FutureBuilder(
            future: futureList,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildSuggestionsListView(snapshot.data);
              } else
                return Container();
            },
          ));
  }

  // build suggestions list view widget
  Widget _buildSuggestionsListView(List<String> suggestions) {
    return suggestions.isEmpty || suggestions[0] == ''
        ? Container()
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              String text = suggestions[index];
              return Container(
                padding: EdgeInsets.all(2),
                child: ListTile(
                  onTap: () {
                    // set textfield text to suggestions[index], keep cursor at the end of the text
                    _textController.text = text;
                    _textController.selection = TextSelection(
                        baseOffset: text.length, extentOffset: text.length);
                    // call submit search
                    _submitSearch(text);
                  },
                  leading: Icon(Icons.search),
                  trailing: Icon(Icons.call_made),
                  //subtitle: Text('SUGGESTION ${index + 1}'),
                  title: Text('$text',
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).accentColor)),
                ),
              );
            },
          );
  }

  // build recent search widget method
  Widget _buildRecentSearch() {
    // does not show recent search when private session is on
    if (widget.model.privateSession) return Container();

    String text = widget.model.savedSearchNewsTitle;
    return Container(
      padding: EdgeInsets.all(2),
      child: ListTile(
        onTap: () {
          // set textfield text to suggestions[index], keep cursor at the end of the text
          _textController.text = text;
          _textController.selection =
              TextSelection(baseOffset: text.length, extentOffset: text.length);
          // call submit search
          _submitSearch(text);
        },
        leading: Icon(Icons.search),
        trailing: Icon(Icons.call_made),
        title: Text('$text',
            style:
                TextStyle(fontSize: 18, color: Theme.of(context).accentColor)),
      ),
    );
  }

  // get suggestions future method
  Future<List<String>> _getSuggestions() async {
    return await Prefs.getSuggestions(_textController.text.toLowerCase())
        .catchError((_) {
      return Future.value([]);
    });
  }

  // clear method, called when pressed 'Clear' iconButton
  void _clear() {
    _textController.clear();
    _clearAnimController.reverse();
    setState(() {
      futureList = _getSuggestions();
    });
  }

  // submit search method called when submit the search
  void _submitSearch(String search) async {
    // check for connectivity before submit search
    bool connectivity = await Connectivity.internetConnectivity();
    if (!connectivity) {
      Fluttertoast.showToast(
        msg: 'There is no internet connection',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // avoid leading and trailing whitespace
    String saveSearch = search.trim();
    // lowerCase all chars
    saveSearch = saveSearch.toLowerCase();
    // saveSuggestions in model if private Session False
    if (!widget.model.privateSession) Prefs.saveSuggestions(saveSearch);

    Navigator.pushNamedAndRemoveUntil(
        context, '/search/${search.trim()}', ModalRoute.withName('/main'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: _buildTitleTextField(),
          actions: <Widget>[
            ScaleTransition(
              scale: CurvedAnimation(
                  parent: _clearAnimController,
                  curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
              child: IconButton(
                tooltip: 'Clear',
                icon: Icon(Icons.clear),
                onPressed: _clear,
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: _unFocusScope,
          child: _buildSuggestions(),
        ),
      ),
    );
  }
}

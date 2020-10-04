import 'package:flutter/material.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/pages/screens/following_page.dart';
import 'package:MyNews/pages/screens/headlines_page.dart';
import 'package:MyNews/pages/screens/saved_articles_page.dart';
//import 'package:MyNews/pages/test/playground.dart';

import 'package:MyNews/widgets/dialogs/welcome_dialog.dart';

import 'package:MyNews/services/prefs_service.dart';

class MainPage extends StatefulWidget {
  final MainModel model;
  final Function changeState;

  MainPage(this.model, this.changeState);

  @override // create state
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  // Class Attributes

  // scaffold global key
  GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  // tab controller
  TabController _tabController;

  // scaffold page body widget
  Widget pageBody;
  // page index integer
  int _pageIndex;
  bool _isVisible = true;
  List<Widget> _bodyWidgetPages;
  PageController _pageController;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // addPostFramecallback so the dialog show after the framework layouts the page
    WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);
    _bodyWidgetPages = [
      HomePage(widget.model, setNavBarVisibility),
      TopicsPage(widget.model, setNavBarVisibility),
      SavedArticlesPage(widget.model, setNavBarVisibility),
      //PlayGroundPage()
    ];
    _pageIndex = 0;
    _pageController = PageController(
      initialPage: _pageIndex,
      keepPage: true,
    );
    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    // dispose controllers
    _tabController?.dispose();
    super.dispose();
  }

  // Animated bottomNavigationBar
  Widget _buildBottomNavigationBar() {
    final bool isDark = MainModel.of(context).isDark;
    return WillPopScope(
      onWillPop: showModalBottomSheet(context: context, builder: (context){
      return Container(
        decoration: BoxDecoration(
            color: Color(0xff737373)
        ),
        height: 100,
        width: double.infinity,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)
                ),
                color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Do you really want to exit?",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none
                    ),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      SizedBox(width: 5,),
                      FlatButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        color: Colors.black,
                        splashColor: Colors.yellowAccent,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(width: 25,),
                      FlatButton(
                        onPressed: (){
                          exit(0);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        color: Colors.white30,
                        splashColor: Colors.yellowAccent,
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 1,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } ),
      child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isVisible ? 56.0 : 0.0,
      child: Wrap(
        children: <Widget>[
          BottomNavigationBar(
            backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
            elevation: 15.0,
            selectedItemColor: Theme.of(context).accentColor,
            unselectedFontSize: 14.0,
            selectedFontSize: 14.0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _pageIndex,
            onTap: _changePage,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.language), title: Text('Headlines')),
              BottomNavigationBarItem(
                  icon: Icon(_pageIndex == 1 ? Icons.star : Icons.star_border),
                  title: Text('Following')),
              BottomNavigationBarItem(
                  icon: Icon(
                      _pageIndex == 2 ? Icons.bookmark : Icons.bookmark_border),
                  title: Text('Saved')),
              //BottomNavigationBarItem(
              //icon: Icon(Icons.bug_report), title: Text('Debug')),
            ],
          )
        ],
      ),
    )
    );
  }

  // show Open Dialog method
  _showOpenDialog(_) async {
    bool value = await Prefs.savedInPrefs('WelcomeDialog');
    if (value) {
      showDialog(
          context: context,
          builder: (context) {
            return WelcomeDialog();
          });
    }
  }

  // change pageBody widget to the given indexs
  void _changePage(int index) {
    MainModel model = widget.model;
    if (_pageIndex == 2) {
      model.callNotifyListeners();
    }
    setState(() {
      _pageIndex = index;
    });

    model.setPageIndex(index);
    _pageController.jumpToPage(index);
  }

  // notify navigation bar visibility
  void setNavBarVisibility(bool visible) {
    setState(() {
      _isVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          key: _scaffoldkey,
          bottomNavigationBar: _buildBottomNavigationBar(),
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: _bodyWidgetPages,
          )),
    );
  }
}

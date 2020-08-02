import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:MyNews/models/news.dart';
import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/widgets/views/web_view_page.dart';
import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';
import 'package:MyNews/widgets/ui_elements/news_widgets/save_button.dart';

class ContentPageView extends StatefulWidget {
  @override
  _ContentPageViewState createState() => _ContentPageViewState();

  final int articleIndex;
  final List<News> newsList;
  final MainModel model;
  final String title;

  ContentPageView(this.articleIndex, this.newsList, this.model, this.title);
}

class _ContentPageViewState extends State<ContentPageView>
    with TickerProviderStateMixin {
  // page view controller
  PageController _pageController;
  // current page view index
  int _currentIndex;
  // scaffold key
  GlobalKey<ScaffoldState> _scaffoldKey;
  // scroll controller
  ScrollController _scrollController;
  bool _isScrolled = false;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // set page controller
    _pageController = PageController(initialPage: widget.articleIndex);
    // set corrent index
    _currentIndex = widget.articleIndex;
    // set sacffold key
    _scaffoldKey = GlobalKey<ScaffoldState>();
    // add listener to scroll controller
    _scrollController = ScrollController()..addListener(_listenToScrollChange);
    super.initState();
  }

  // build bottom app bar widget
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 5.0,
          ),
          ScopedModelDescendant<MainModel>(
            builder: (context, child, model) {
              return SaveButton(widget.model, widget.newsList[_currentIndex]);
            },
          ),
          SizedBox(
            width: 5.0,
          ),
          IconButton(
            tooltip: 'Share',
            icon: Icon(
              Icons.share,
            ),
            onPressed: () => Share.share(
                'Check this article:\n\n' + widget.newsList[_currentIndex].url),
          ),
          Spacer(),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
            color: Theme.of(context).accentColor,
            child: Row(
              children: <Widget>[
                Text(
                  'FULL ARTICLE',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  Icons.launch,
                  color: Colors.white,
                ),
              ],
            ),
            onPressed: () {
              _openInWebView(customURL: widget.newsList[_currentIndex].url);
            },
          ),
          SizedBox(
            width: 6,
          )
        ],
      ),
    );
  }

  // build scaffold body widget
  Widget _buildScaffoldBody() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      onPageChanged: (index) {
        _currentIndex = index;
        setState(() {
          _isScrolled = false;
        });
        //widget.model.notifyModel();
      },
      itemBuilder: (context, index) {
        final News news = widget.newsList[index];
        return CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              expandedHeight: 256.0,
              pinned: false,
              title: AnimatedOpacity(
                  opacity: _isScrolled ? 1.0 : 0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: AppBarTitle(widget.title),
                  )),
              flexibleSpace: FlexibleSpaceBar(
                background: FadeInImage(
                  image: news.urlToImage == 'Assets/images/placeHolder.jpg'
                      ? AssetImage('Assets/images/placeHolder.jpg')
                      : NetworkImage(news.urlToImage),
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('Assets/images/loading.jpg'),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      _buildAutorSource(news),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          news.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _buildContent(news),
                      SizedBox(
                        height: 10,
                      ),
                      _buildFullCoverageText()
                    ],
                  ))
            ]))
          ],
        );
      },
      itemCount: widget.newsList.length,
    );
  }

  // build Source text widget
  Widget _buildAutorSource(News news) {
    String published = news.publishedAt.replaceAll('/', '');
    DateTime publishedTime = DateTime.parse(published);
    Duration difference = DateTime.now().difference(publishedTime);
    if (difference.inDays == 0) {
      published = 'Today';
    } else if (difference.inDays == 1) {
      published = 'Yesterday';
    } else {
      published = news.publishedAt;
    }
    return Container(
        alignment: Alignment.topLeft,
        child: Text(
          '${news.source} \u{2022} $published',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 11,
          ),
        ));
  }

  // build content widget method
  Widget _buildContent(News news) {
    String text = '';

    // content
    if (news.content != 'No content') {
      text = news.content.replaceAll('\n', '');
      int endContentIndex = text.indexOf('[');
      if (endContentIndex != -1) {
        text = text.substring(0, endContentIndex);
      }
      // description
    } else if (news.description != 'No description') {
      text = news.description.replaceAll('\n', ' ');
    }
    // remove any letter that is not a-z, A-Z
    List<String> words = text.split(' ');
    words.removeWhere((item) => !item.contains(RegExp(r'[a-zA-Z]')));
    text = words.join(' ');

    // bac letters check before manipulate text string
    int badLetters = 0;
    for (int i = 0; i < text.length; i++) {
      if ([',', '.', '\'', '\"', '\:', '(', ')', '[', ']'].contains(text[i])) {
        badLetters++;
      }
    }
    if (badLetters > 10) {
      text = '';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 18,
            color: widget.model.isDark ? Colors.white : Colors.black,
            fontFamily: 'Roboto'),
      ),
    );
  }

  // build full coverage text method
  Widget _buildFullCoverageText() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        '\n\nFor full coverage click the button bellow'.toUpperCase(),
        style: TextStyle(
            color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w800),
        textAlign: TextAlign.center,
      ),
    );
  }

  // open url in WebViewPage
  Future<Null> _openInWebView({String customURL}) async {
    String url;
    if (customURL == null) {
      url = widget.newsList[_currentIndex].url;
    } else {
      url = customURL;
    }
    // if canLaunch url
    if (await canLaunch(url)) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WebViewPage(
                title: widget.newsList[_currentIndex].source,
                url: url,
              )));
      // failed to launch url, showSnackBar
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Failed to launch url'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // listen to scroll change method
  _listenToScrollChange() {
    if (_scrollController.offset > 180) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: _buildBottomAppBar(),
          body: _buildScaffoldBody(),
        ));
  }
}

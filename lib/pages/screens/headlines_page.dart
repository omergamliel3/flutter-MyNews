import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/widgets/views/news_page.dart';
import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  // HomePage Constructor
  final MainModel model;
  final Function setNavBarVisibility;

  HomePage(this.model, this.setNavBarVisibility);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Class Attributes
  // scroll controller
  ScrollController _scrollController;
  TabController _tabController;
  bool showTabs;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    _scrollController = ScrollController();
    // listen to scroll direction
    _scrollController.addListener(() {
      // add false to sink  when scroll reverse
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.setNavBarVisibility(false);
        // add true to sink when scroll forward
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.setNavBarVisibility(true);
      }
    });

    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  void dispose() {
    if (showTabs) _tabController.dispose();
    super.dispose();
  }

  void handleTabs() {
    if (widget.model.searchCountry == null ||
            widget.model.searchCountryNotSupported ??
        false) {
      showTabs = false;
    } else {
      showTabs = true;
    }
    if (showTabs) {
      // set tab Controller
      _tabController = TabController(
        initialIndex: widget.model.homePageTabBarindex,
        length: 2,
        vsync: this,
      );

      _tabController.addListener(() {
        widget.model.setHomePageTabBarIndex(_tabController.index);
      });
    }
  }

  // build TabBar widget method
  Widget _buildTabBar() {
    // if search country is Null, dont return TabBar.
    if (!showTabs) {
      return PreferredSize(
        child: Container(),
        preferredSize: Size.zero,
      );
    }

    return TabBar(
        labelColor: Theme.of(context).accentColor,
        unselectedLabelColor: widget.model.isDark ? Colors.white : Colors.black,
        controller: _tabController,
        tabs: [widget.model.searchCountry, 'World']
            .map((e) => Tab(child: Text(e)))
            .toList());
  }

  // build _TabBarView widget method
  Widget _tabBarView() {
    // if search country is Null return only World News
    if (!showTabs) {
      return NewsPage(
        headlines: true,
        model: widget.model,
        index: 1,
      );
    }

    return TabBarView(controller: _tabController, children: [
      NewsPage(
        headlines: true,
        model: widget.model,
        index: 0,
      ),
      NewsPage(
        headlines: true,
        model: widget.model,
        index: 1,
      )
    ]);
  }

  // build actions List<Widget> method
  List<Widget> _buildActions() {
    Widget settingsButton = IconButton(
        tooltip: 'Settings',
        icon: Icon(
          Icons.settings,
          size: 25,
        ),
        onPressed: () => Navigator.pushNamed(context, '/settings'));

    Widget searchButton = IconButton(
      tooltip: 'Search',
      // Icon Button to open search dialog
      icon: Icon(
        Icons.search,
        size: 25,
      ),
      // show search dialog when pressed
      onPressed: () {
        Navigator.pushNamed(context, '/custom_search');
      },
    );
    return [searchButton, settingsButton];
  }

  @override
  Widget build(BuildContext context) {
    handleTabs();
    return Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                primary: true,
                forceElevated: innerBoxIsScrolled,
                title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: AppBarTitle('Headlines'),
                ),
                actions: _buildActions(),
                bottom: _buildTabBar(),
              ),
            ];
          },
          body: _tabBarView()),
    );
  }
}

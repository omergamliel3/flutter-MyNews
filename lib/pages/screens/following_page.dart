import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:MyNews/widgets/views/news_page.dart';
import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

class TopicsPage extends StatefulWidget {
  @override
  _TopicsPageState createState() => _TopicsPageState();

  final MainModel model;
  final Function setNavBarVisibility;
  TopicsPage(this.model, this.setNavBarVisibility);
}

class _TopicsPageState extends State<TopicsPage> with TickerProviderStateMixin {
  // tab controller
  TabController _tabController;
  // list view scroll controller
  ScrollController _scrollController;

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // build TabBar widget method
  TabBar _buildTabBar(TabController _tabController) {
    var tabBar = TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).accentColor,
        unselectedLabelColor: widget.model.isDark ? Colors.white : Colors.black,
        tabs: List.generate(
            widget.model.getfollowingTopicsList.length,
            (index) => Tab(
                  child: Text(
                    widget.model.getfollowingTopicsList[index],
                    textAlign: TextAlign.center,
                  ),
                )));
    return tabBar;
  }

  // build actions widget method
  List<Widget> _buildActions() {
    var actions = <Widget>[
      IconButton(
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
      ),
      IconButton(
          tooltip: 'Settings',
          icon: Icon(
            Icons.settings,
            size: 25,
          ),
          onPressed: () => Navigator.pushNamed(context, '/settings'))
    ];
    return actions;
  }

  // build tab controller
  TabController _buildTabController() {
    var _tabController = TabController(
        initialIndex: widget.model.followingPageTabBarIndex,
        length: widget.model.getfollowingTopicsList.length,
        vsync: this);
    _tabController.addListener(() {
      widget.model.setTabBarIndex(_tabController.index);
    });
    return _tabController;
  }

  @override
  Widget build(BuildContext context) {
    // build tab controller every time the page is build to keep the tabs length updated
    _tabController = _buildTabController();

    return Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          physics: ScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled,
                title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: AppBarTitle('Following'),
                ),
                actions: _buildActions(),
                bottom: _buildTabBar(_tabController),
              )
            ];
          },
          body: TabBarView(
              controller: _tabController,
              children: List.generate(
                  widget.model.getfollowingTopicsList.length,
                  (_index) => NewsPage(model: widget.model, index: _index)))),
    );
  }
}

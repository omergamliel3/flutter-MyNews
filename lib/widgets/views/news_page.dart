import 'dart:async';

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:MyNews/models/news.dart';
import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/services/custom_services.dart';

import 'package:MyNews/widgets/ui_elements/global_widgets/loading_shader_mask.dart';
import 'package:MyNews/widgets/ui_elements/news_widgets/news_card.dart';

class NewsPage extends StatefulWidget {
  // Class Attributes

  final MainModel model;
  final int index;
  final bool saveSearch;
  final bool headlines;
  final String search;

  // NewsPage Constructor
  NewsPage(
      {this.model,
      this.index,
      this.saveSearch = false,
      this.headlines = false,
      this.search});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // future value
  Future<Map<String, dynamic>> _future;

  // Called when this object is inserted into the tree.
  @override
  void initState() {
    // init future
    if (widget.saveSearch) {
      _future = fetchNews(forceFetch: true);
    }
    // init global keys
    super.initState();
  }

  // loading widget
  Widget _buildLoadingWidget() {
    Widget loadingShadeMask = Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: LoadingShaderMask(
        targetWidth: MediaQuery.of(context).size.width * 0.9,
        targetHeight: MediaQuery.of(context).size.height * 0.4,
      ),
    );
    return ListView(
        padding: const EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        children: <Widget>[
          loadingShadeMask,
          loadingShadeMask,
          loadingShadeMask,
          loadingShadeMask,
          loadingShadeMask
        ]);
  }

  // // build Error widget method
  Widget _buildErrorWidget(String error) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(15.0),
      child: Text(
        error,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  // hangle error method
  Widget _handleError(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    // error cases
    // On There is no internet connection error
    if (snapshot.data['message'] == 'There is no internet connection') {
      repeateCheckConnectivity();
    }
    return _buildErrorWidget(snapshot.data['message']);
  }

  // NewsCard List view builder
  Widget _buildNewsCardListView() {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      List<News> newsList;
      // adjust newsList reference if saveSearch mode or not
      if (widget.saveSearch) {
        newsList = widget.model.getSearchNews;
      } else if (widget.headlines) {
        newsList = model.headlinesNewsList[widget.index];
      } else {
        try {
          newsList = model.getNewsList[widget.index];
        } on RangeError {
          return Container();
        }
      }

      if (newsList.isEmpty) {
        return _buildLoadingWidget();
      } else {
        return ListView.builder(
          addAutomaticKeepAlives: true,
          physics: ScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          itemBuilder: (context, index) {
            return NewsCard(newsList[index], widget.model, index);
          },
          itemCount: newsList.length,
        );
      }
    });
  }

  // fetch news method
  Future<Map<String, dynamic>> fetchNews({forceFetch = false}) {
    // on SearchPage
    if (widget.saveSearch) {
      return widget.model.fetchNews(
          search: widget.search,
          saveSearchNews: widget.saveSearch,
          forceFetch: forceFetch);
      // on home page
    } else if (widget.headlines) {
      return widget.model.fetchNews(
          index: widget.index, forceFetch: forceFetch, headlines: true);
    } else {
      return widget.model.fetchNews(
          search: widget.model.getfollowingTopicsList[widget.index],
          index: widget.index,
          forceFetch: forceFetch);
    }
  }

  // checks every second connectivity
  void repeateCheckConnectivity() async {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      bool connectivity = await Connectivity.internetConnectivity();
      // if connectivity is true call fetchNews and cancel timer
      if (connectivity) {
        timer.cancel();
        Fluttertoast.showToast(
          msg: 'Internet connection restored',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        await fetchNews(forceFetch: true);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // prevent re-build futureBuilder again when already fetched
    List<News> newsList;
    // adjust newsList
    if (widget.saveSearch) {
      newsList = widget.model.getSearchNews;
    } else if (widget.headlines) {
      newsList = widget.model.headlinesNewsList[widget.index];
    } else {
      newsList = widget.model.getNewsList[widget.index];
    }
    if (newsList.isNotEmpty) {
      return _buildNewsCardListView();
    } else
      return FutureBuilder<Map<String, dynamic>>(
        future: widget.saveSearch ? _future : fetchNews(forceFetch: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // future complete
            // if error or data is false return error widget
            if (snapshot.hasError) {
              return _buildErrorWidget('SOMETHING WENT WRONG, TAP TO RELOAD');
            }
            if (snapshot.data['error']) {
              return _handleError(snapshot);
            }
            // return news card listview
            return _buildNewsCardListView();

            // return loading widget while connection state is active
          } else {
            return _buildLoadingWidget();
          }
        },
      );
  }
}

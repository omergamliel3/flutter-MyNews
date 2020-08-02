import 'package:flutter/material.dart';

import 'package:MyNews/models/article.dart';

import 'package:MyNews/services/db_service.dart';
import 'package:MyNews/services/custom_services.dart';

class PlayGroundPage extends StatefulWidget {
  @override
  _PlayGroundPageState createState() => _PlayGroundPageState();
}

class _PlayGroundPageState extends State<PlayGroundPage> {
  bool show = false;
  List<Article> articleDataList = [];
  Widget displayWidget;

  @override
  void initState() {
    displayWidget = Center(child: CircularProgressIndicator());
    _fetchSavedArticles();
    super.initState();
  }

  Future<void> _fetchSavedArticles() async {
    articleDataList = await DBservice.getArticles();
    await Future.delayed(Duration(seconds: 2));
    changeUI();
  }

  void changeUI() {
    if (mounted)
      setState(() {
        if (articleDataList.isEmpty) {
          displayWidget = Text('DB is empty');
        } else {
          displayWidget = TabBarView(
              children: List.generate(
                  2,
                  (index) => RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(Duration(seconds: 1));
                        print('onRefresh callback');
                        return;
                      },
                      child: ListView.builder(
                          key: PageStorageKey('PGListViewKey$index'),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: articleDataList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    articleDataList[index].urlToImage),
                              ),
                              title: Text(articleDataList[index].title),
                              subtitle: Text(
                                  articleDataList[index].id.toString() +
                                      articleDataList[index].source),
                              trailing: Text(
                                  articleDataList[index].date.substring(0, 10)),
                              onTap: () {
                                LaunchUrlHelper.launchURL(
                                    articleDataList[index].url);
                              },
                              onLongPress: () {
                                if (index == 0)
                                  DBservice.updateArticle(
                                      articleDataList[index]);
                                else
                                  DBservice.deleteArticle(
                                      articleDataList[index].url);

                                setState(() {
                                  displayWidget = displayWidget = Center(
                                      child: CircularProgressIndicator());
                                });
                                _fetchSavedArticles();
                              },
                            );
                          }))));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text('PlayGround'),
              ),
              bottom: TabBar(tabs: [
                Tab(text: 'Tab 1', icon: Icon(Icons.bug_report)),
                Tab(text: 'Tab 2', icon: Icon(Icons.bug_report)),
              ]),
            ),
            body: displayWidget));
  }
}

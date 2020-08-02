import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:MyNews/scoped-models/main.dart';
import 'package:MyNews/helpers/custom_extentions.dart';

import 'package:MyNews/models/article.dart';

import 'package:MyNews/services/db_service.dart';

import 'package:MyNews/shared/global_values.dart';

import 'package:MyNews/widgets/views/web_view_page.dart';

class SavedArticleListTile extends StatelessWidget {
  // class attributes
  final Article article;
  final int index;
  // constructor
  SavedArticleListTile(this.article, this.index);

  Future<Null> _openInWebView(
      BuildContext context, String url, String title) async {
    // if canLaunch url
    if (await canLaunch(url)) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WebViewPage(
                title: title,
                url: url,
              )));
      // failed to launch url, showSnackBar
    } else {
      if (Scaffold.of(context) != null)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Failed to launch url'),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  Widget _buildFadeInImage() {
    return Container(
        padding: EdgeInsets.zero,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: FadeInImage.assetNetwork(
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 700),
              placeholder: loadingImageAsset,
              image: article.urlToImage,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  placeHolderAsset,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                );
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    // widgets variables
    TextDirection _textDirection;
    Alignment _alignment;

    if (article.textDirection == 'ltr') {
      _textDirection = TextDirection.ltr;

      _alignment = Alignment.topLeft;
    } else {
      _textDirection = TextDirection.rtl;
      _alignment = Alignment.topRight;
    }

    return Column(
      children: <Widget>[
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: _alignment,
                child: Directionality(
                  textDirection: _textDirection,
                  child: Text(
                    article.title,
                    style: TextStyle(
                        color: MainModel.of(context).isDark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      article.source,
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 11),
                    ),
                    Text(
                      ' \u{2022} ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      article.date.getTimeAgo(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    )
                  ],
                ),
              ),
            ],
          ),
          trailing: _buildFadeInImage(),
          onTap: () => _openInWebView(context, article.url, article.title),
        ),
        if (index != DBservice.savedArticles.length - 1)
          const Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Divider(thickness: .5, color: Colors.grey),
          )
      ],
    );
  }
}

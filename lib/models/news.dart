import 'package:flutter/material.dart';

// News Class to store news content from News API.
class News {
  String author;
  String source;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;
  String textDir;
  String createdTime;

  // News Constructor
  News(
      {@required this.author,
      @required this.source,
      @required this.title,
      @required this.description,
      @required this.url,
      @required this.urlToImage,
      @required this.publishedAt,
      @required this.content,
      @required this.textDir,
      @required this.createdTime});

  // fromMap Constructor
  News.fromMap(
      {@required Map<String, dynamic> newsData, String textDirection}) {
    // parssing data from Map object
    String author = newsData['author'] ?? 'Unknown author';
    author = author.replaceAll('\"', "");
    String source = newsData['source']['name'] ?? 'Unknown source';
    source = source.replaceAll('\"', "");
    String title = newsData['title'] ?? 'No title';
    title = title.replaceAll("\"", "''");
    String description = newsData['description'] ?? 'No description';
    description = description.replaceAll('\"', "");
    String content = newsData['content'] ?? 'No content';
    content = content.replaceAll('\"', "");
    String url = newsData['url'] ?? 'No url';
    url = url.replaceAll('\"', "");
    String urlToImage =
        newsData['urlToImage'] ?? 'Assets/images/placeHolder.jpg';
    urlToImage = urlToImage.replaceAll('\"', "");
    String publishedAt = newsData['publishedAt'];
    publishedAt = publishedAt.replaceAll('\"', '');

    this.author = author;
    this.source = source;
    this.title = title;
    this.description = description;
    this.content = content;
    this.source = source;
    this.url = url;
    this.urlToImage = urlToImage;
    this.publishedAt = publishedAt;
    this.textDir = textDirection;
    this.createdTime = DateTime.now().toIso8601String();
  }

  News.fromDBmap(Map<String, dynamic> map) {
    this.author = map['author'];
    this.source = map['source'];
    this.title = map['title'];
    this.description = map['description'];
    this.url = map['url'];
    this.urlToImage = map['urlToImage'];
    this.publishedAt = map['publishedAt'];
    this.content = map['content'];
    this.textDir = map['textDir'];
    this.createdTime = map['createTime'];
  }
}
